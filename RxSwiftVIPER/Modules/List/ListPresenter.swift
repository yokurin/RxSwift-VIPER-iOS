//
//  ListPresenter.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
/// Must not import UIKit

typealias ListPresenterDependencies = (
    interactor: ListInteractor,
    router: ListRouterOutput
)

protocol ListPresenterInputs {
    var viewDidLoadTrigger: PublishSubject<Void> { get }
    var closeButtonTappedTrigger: PublishSubject<Void> { get }
    var reachedBottomTrigger: PublishSubject<Void> { get }
    var didSelectRowTrigger: PublishSubject<IndexPath>  { get }
}

protocol ListPresenterOutputs {
    var gitHubRepositories: BehaviorRelay<[GitHubRepository]> { get }
    var viewConfigure: Observable<ListEntryEntity> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<NSError> { get }
}

protocol ListPresenterInterface {
    var inputs: ListPresenterInputs { get }
    var outputs: ListPresenterOutputs { get }
}

final class ListPresenter: ListPresenterInterface, ListPresenterInputs, ListPresenterOutputs {

    var inputs: ListPresenterInputs { return self }
    var outputs: ListPresenterOutputs { return self }

    class SearchApiState {
        var page: Int
        var language: String

        init(language: String, page: Int) {
            self.language = language
            self.page = page
        }
    }

    // Inputs
    let viewDidLoadTrigger = PublishSubject<Void>()
    let closeButtonTappedTrigger = PublishSubject<Void>()
    let reachedBottomTrigger = PublishSubject<Void>()
    let didSelectRowTrigger = PublishSubject<IndexPath>()

    // Outputs
    let gitHubRepositories = BehaviorRelay<[GitHubRepository]>(value: [])
    let viewConfigure: Observable<ListEntryEntity>
    let isLoading: Observable<Bool>
    let error: Observable<NSError>

    private var searchApiState: SearchApiState
    private let dependencies: ListPresenterDependencies
    private let disposeBag = DisposeBag()

    init(entryEntity: ListEntryEntity,
         dependencies: ListPresenterDependencies)
    {

        self.dependencies = dependencies
        self.searchApiState = SearchApiState(language: entryEntity.language, page: 1)

        self.error = dependencies.interactor.searchActionError
        self.isLoading = dependencies.interactor.searchActionIsLoading

        let _viewConfigure = PublishRelay<ListEntryEntity>()
        self.viewConfigure = _viewConfigure.asObservable().take(1)

        viewDidLoadTrigger.asObservable()
            .withLatestFrom(Observable.just(entryEntity))
            .bind(to: _viewConfigure)
            .disposed(by: disposeBag)

        closeButtonTappedTrigger.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.dependencies.router.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        reachedBottomTrigger.asObservable()
            .withLatestFrom(Observable.just(searchApiState))
            .filter { $0.page < 5 }
            .map { GitHubApi.SearchRequest(language: $0.language, page: $0.page) }
            .withLatestFrom(isLoading) { ($0, $1) }
            .filter { !$0.1 }
            .map { $0.0 }
            .bind(to: dependencies.interactor.seachActionTrigger)
            .disposed(by: disposeBag)

        didSelectRowTrigger.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: transitionDetail)
            .disposed(by: disposeBag)

        dependencies.interactor.searchResponse
            .map { $0.items }
            .withLatestFrom(gitHubRepositories) { ($1, $0) }
            .map { $0.0 +  $0.1 }
            .subscribe(onNext: { [weak self] gitHubRepositories in
                self?.gitHubRepositories.accept(gitHubRepositories)
                self?.searchApiState.page += 1
            })
            .disposed(by: disposeBag)
    }

    private func transitionDetail(indexPath: IndexPath) {
        guard let repo = gitHubRepositories.value[safe: indexPath.row] else { return }
        dependencies.router.transitionDetail(gitHubRepository: repo)
    }

}


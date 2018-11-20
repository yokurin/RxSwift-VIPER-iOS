//
//  DetailPresenter.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import Foundation
import WebKit
import RxCocoa
import RxSwift


protocol DetailPresenterInputs {
    var viewDidLoadTrigger: PublishSubject<Void> { get }
}

protocol DetailPresenterOutputs {
    var viewConfigure: Observable<DetailEntryEntity> { get }
    var webViewRequest: Observable<URLRequest> { get }
}

protocol DetailPresenterInterface {
    var inputs: DetailPresenterInputs { get }
    var outputs: DetailPresenterOutputs { get }
}

typealias DetailPresenterDependencies = (
    interactor: DetailInteractor,
    router: DetailRouterOutput
)

final class DetailPresenter: DetailPresenterInterface, DetailPresenterInputs, DetailPresenterOutputs {
    var inputs: DetailPresenterInputs { return self }
    var outputs: DetailPresenterOutputs { return self }

    // Inputs
    let viewDidLoadTrigger = PublishSubject<Void>()

    // Outputs
    let viewConfigure: Observable<DetailEntryEntity>
    let webViewRequest: Observable<URLRequest>

    private let entryEntity: DetailEntryEntity
    private let dependencies: DetailPresenterDependencies
    private let disposeBag = DisposeBag()

    init(entryEntity: DetailEntryEntity,
         dependencies: DetailPresenterDependencies)
    {
        self.entryEntity = entryEntity
        self.dependencies = dependencies

        let _viewConfigure = PublishRelay<DetailEntryEntity>()
        self.viewConfigure = _viewConfigure.asObservable().take(1)

        let _webViewRequest = PublishRelay<URLRequest>()
        self.webViewRequest = _webViewRequest.asObservable().take(1)

        viewDidLoadTrigger.asObservable()
            .subscribe(onNext: { [weak self] in
                _viewConfigure.accept(entryEntity)
                guard let urlString = self?.entryEntity.gitHubRepository.url,
                    let url = URL(string: urlString) else { return }
                _webViewRequest.accept(URLRequest(url: url))
            })
            .disposed(by: disposeBag)
    }
}


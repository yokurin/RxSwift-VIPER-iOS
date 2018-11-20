//
//  ListInteractor.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Action
import APIKit

final class ListInteractor {

    // Inputs
    let seachActionTrigger = InputSubject<GitHubApi.SearchRequest>()

    // Outputs
    private let searchAction: Action<GitHubApi.SearchRequest, SearchRepositoriesResponse>
    let searchResponse: Observable<SearchRepositoriesResponse>
    let searchActionIsLoading: Observable<Bool>
    let searchActionError: Observable<NSError>

    private let disposeBag = DisposeBag()

    init() {

        self.searchAction = Action { request in
            return Session.shared.rx.send(request)
        }

        let _searchResponse = PublishRelay<SearchRepositoriesResponse>()
        self.searchResponse = _searchResponse.asObservable()

        self.searchActionIsLoading = searchAction.executing.startWith(false)
        self.searchActionError = searchAction.errors.map { _ in NSError(domain: "Network Error", code: 0, userInfo: nil) }

        searchAction.elements.asObservable()
            .bind(to: _searchResponse)
            .disposed(by: disposeBag)

        seachActionTrigger.asObservable()
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
    }

}

//
//  ListRouter.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import Foundation
import UIKit

struct ListEntryEntity {
    let language: String
}

struct ListRouterInput {

    private func view(entryEntity: ListEntryEntity) -> ListViewController {
        let view = ListViewController()
        let interactor = ListInteractor()
        let dependencies = ListPresenterDependencies(interactor: interactor, router: ListRouterOutput(view))
        let presenter = ListPresenter(entryEntity: entryEntity, dependencies: dependencies)
        view.presenter = presenter
        return view
    }

    func push(from: Viewable, entryEntity: ListEntryEntity) {
        let view = self.view(entryEntity: entryEntity)
        from.push(view, animated: true)
    }

    func present(from: Viewable, entryEntity: ListEntryEntity) {
        let nav = UINavigationController(rootViewController: view(entryEntity: entryEntity))
        from.present(nav, animated: true)
    }
}

final class ListRouterOutput: Routerable {

    private(set) weak var view: Viewable!

    init(_ view: Viewable) {
        self.view = view
    }

    func transitionDetail(gitHubRepository: GitHubRepository) {
        DetailRouterInput().push(from: view, entryEntity: DetailEntryEntity(gitHubRepository: gitHubRepository))
    }
}


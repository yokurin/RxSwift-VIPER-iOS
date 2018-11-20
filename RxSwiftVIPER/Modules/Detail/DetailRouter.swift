//
//  DetailRouter.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import Foundation
import UIKit

struct DetailEntryEntity {
    let gitHubRepository: GitHubRepository
    init(gitHubRepository: GitHubRepository) {
        self.gitHubRepository = gitHubRepository
    }
}

struct DetailRouterInput {

    private func view(entryEntity: DetailEntryEntity) -> DetailViewController {
        let view = DetailViewController()
        let interactor = DetailInteractor()
        let dependencies = DetailPresenterDependencies(interactor: interactor, router: DetailRouterOutput(view))
        let presenter = DetailPresenter(entryEntity: entryEntity, dependencies: dependencies)
        view.presenter = presenter
        return view
    }

    func push(from: Viewable, entryEntity: DetailEntryEntity) {
        let view = self.view(entryEntity: entryEntity)
        from.push(view, animated: true)
    }

    func present(from: Viewable, entryEntity: DetailEntryEntity) {
        let nav = UINavigationController(rootViewController: view(entryEntity: entryEntity))
        from.present(nav, animated: true)
    }
}

final class DetailRouterOutput: Routerable {

    private(set) weak var view: Viewable!

    init(_ view: Viewable) {
        self.view = view
    }

}


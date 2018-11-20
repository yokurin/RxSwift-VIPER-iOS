//
//  ViewController.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBAction func pushListScreenAction(_ sender: Any) {
        ListRouterInput().push(from: self, entryEntity: ListEntryEntity(language: "RxSwift"))
    }

    @IBAction func presentListScreenAction(_ sender: Any) {
        ListRouterInput().present(from: self, entryEntity: ListEntryEntity(language: "RxSwift"))
    }

}

extension ViewController: Viewable {}

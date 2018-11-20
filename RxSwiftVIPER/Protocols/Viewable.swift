//
//  Viewable.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import Foundation
import UIKit

protocol Viewable: AnyObject {
    func push(_ vc: UIViewController, animated: Bool)
    func present(_ vc: UIViewController, animated: Bool)
    func pop(animated: Bool)
    func dismiss(animated: Bool)
    func dismiss(animated: Bool, _completion:  @escaping (() -> Void))
}

extension Viewable where Self: UIViewController {

    func push(_ vc: UIViewController, animated: Bool) {
        self.navigationController?.pushViewController(vc, animated: animated)
    }

    func present(_ vc: UIViewController, animated: Bool) {
        self.present(vc, animated: animated, completion: nil)
    }

    func pop(animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
    }

    func dismiss(animated: Bool) {
        self.dismiss(animated: animated, completion: nil)
    }

    func dismiss(animated: Bool, _completion: @escaping (() -> Void)) {
        self.dismiss(animated: animated, completion: _completion)
    }

    var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

}

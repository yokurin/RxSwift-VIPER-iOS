//
//  SessionExtension.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import Foundation
import RxSwift
import APIKit

extension Session: ReactiveCompatible {}

extension Reactive where Base: Session {
    func send<T: Request>(_ request: T) -> Single<T.Response> {
        return Single<T.Response>.create { [weak base] observer -> Disposable in
            guard let _base = base else { return Disposables.create() }
            let task = _base.send(request) { result in
                switch result {
                case .success(let value):
                    #if DEBUG
                    //                    print("------------ Success API Request ------------")
                    //                    print("\(value)")
                    //                    print("---------------------------------------------")
                    #endif

                    observer(.success(value))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create { task?.cancel() }
        }
    }
}

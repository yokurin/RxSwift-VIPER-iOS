//
//  DetailViewController.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WebKit
import RxWebKit

final class DetailViewController: UIViewController {

    var presenter: DetailPresenterInterface!

    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var webView: WKWebView!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.rx.loading
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        presenter.outputs.viewConfigure
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] entryEntity in
                self?.navigationItem.title = entryEntity.gitHubRepository.fullName
            })
            .disposed(by: disposeBag)

        presenter.outputs.webViewRequest
            .subscribe(onNext: { [weak self] request in
                self?.webView.load(request)
            })
            .disposed(by: disposeBag)

        presenter.inputs.viewDidLoadTrigger.onNext(())
    }
}

extension DetailViewController: Viewable {}

//
//  ListViewController.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListViewController: UIViewController {

    var presenter: ListPresenterInterface!

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var closeButton: UIButton!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.isHidden = navigationController?.viewControllers.count != 1

        closeButton.rx.tap.asDriver()
            .drive(presenter.inputs.closeButtonTappedTrigger)
            .disposed(by: disposeBag)

        presenter.outputs.viewConfigure
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] entryEntity in
                self?.navigationItem.title = "\(entryEntity.language) Repositories"
            })
            .disposed(by: disposeBag)

        presenter.outputs.gitHubRepositories.asObservable()
            .filter { !$0.isEmpty }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        presenter.outputs.isLoading
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        presenter.outputs.isLoading
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isLoading ? 50 : 0, right: 0)
            })
            .disposed(by: disposeBag)

        presenter.outputs.error
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isLoading in
                let ac = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true)
            })
            .disposed(by: disposeBag)

        tableView.rx.reachedBottom.asObservable()
            .bind(to: presenter.inputs.reachedBottomTrigger)
            .disposed(by: disposeBag)

        // First View Load
        presenter.inputs.viewDidLoadTrigger.onNext(())
        // First Data Fetch
        presenter.inputs.reachedBottomTrigger.onNext(())

    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.outputs.gitHubRepositories.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let repo = presenter.outputs.gitHubRepositories.value[safe: indexPath.row] else { return UITableViewCell() }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "subtitle")
        cell.textLabel?.text = "\(repo.fullName)"
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.detailTextLabel?.text = "\(repo.description)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.inputs.didSelectRowTrigger.onNext(indexPath)
    }

}

extension ListViewController: Viewable {}

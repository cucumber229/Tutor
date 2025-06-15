//
//  TutorListViewController.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import UIKit
import SnapKit
import Foundation

protocol TutorListViewControllerProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showTutors()
}

final class TutorListViewController: UIViewController {
    // Dependencies
    
    // MARK: UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.register(TutorTableViewCell.self, forCellReuseIdentifier: "\(TutorTableViewCell.self)")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    // MARK: MVP Properties
    var presenter: TutorListPresenterProtocol!
    
    // MARK:  Lifecycle
    override func viewDidLoad() {
        setupUI()
        presenter.loadTutors()
        super.viewDidLoad()
    }
}

// MARK: - Public methods

extension TutorListViewController: TutorListViewControllerProtocol {
    func showLoading() {
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
    }

    func showTutors() {
        tableView.reloadData()
    }
}
// MARK: - Private Methods

private extension TutorListViewController {
    func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
    }
    
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.left.right.top.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - objc methods

private extension TutorListViewController {
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TutorListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.tutors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(TutorTableViewCell.self)"
        ) as? TutorTableViewCell
        else {
            fatalError("Couldn't register cell")
        }
        cell.configure(with: presenter.tutors[indexPath.row])
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.showTutorDetail(indexPath: indexPath)
    }
}

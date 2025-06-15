//
//  MyBookingsViewController.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 15.06.2025.
//

import Foundation
import UIKit

protocol MyBookingsViewControllerProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showBookings()
}

final class MyBookingsViewController: UIViewController {
    
    // MARK: UI
    
    private lazy var modeSwitcher: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Ученик", "Репетитор"])
        control.selectedSegmentIndex = 1
        control.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
        control.backgroundColor = .clear
        control.isHidden = true
        control.selectedSegmentTintColor = UIColor.systemBlue
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(MyBookingTableViewCell.self, forCellReuseIdentifier: "\(MyBookingTableViewCell.self)")
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    // MARK: MVP Properties
    
    var presenter: MyBookingsPresenterProtocol!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidLoad()
    }
}

// MARK: - Private methods

private extension MyBookingsViewController {
    func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
    }
    
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(modeSwitcher)
        view.addSubview(activityIndicator)
        activityIndicator.isHidden = true
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

private extension MyBookingsViewController {
    @objc private func modeChanged(_ sender: UISegmentedControl) {
        presenter.selectedMode = sender.selectedSegmentIndex == 0 ? .student : .tutor
        tableView.reloadData()
    }
}

// MARK: - MyBookingsViewControllerProtocol

extension MyBookingsViewController: MyBookingsViewControllerProtocol {
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    func showBookings() {
        setupUI()
        if presenter.isTutor {
            modeSwitcher.isHidden = false
            modeSwitcher.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(44)
            }

            tableView.snp.remakeConstraints {
                $0.top.equalTo(modeSwitcher.snp.bottom).offset(12)
                $0.left.right.bottom.equalToSuperview()
            }
        } else {
            modeSwitcher.isHidden = true
        }

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MyBookingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.currentBookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MyBookingTableViewCell.self)")
                as? MyBookingTableViewCell else {
            fatalError("Couldn't register cell")
        }

        let booking = presenter.currentBookings[indexPath.row]
        cell.configure(with: booking)
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

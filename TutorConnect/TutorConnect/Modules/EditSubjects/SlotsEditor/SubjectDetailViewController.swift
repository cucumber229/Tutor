//
//  SubjectDetailViewController.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import UIKit
import FirebaseCore

protocol SubjectDetailViewControllerProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showSlots()
}

final class SubjectDetailViewController: UIViewController {
    
    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
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
    
    // MARK: - MVP Properties
    
    var presenter: SubjectDetailPresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = .white
        title = presenter.subject.name
    }
}

// MARK: - Private methods

private extension SubjectDetailViewController {
    func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddSlot)
        )
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

// MARK: - SubjectDetailViewControllerProtocol

extension SubjectDetailViewController: SubjectDetailViewControllerProtocol {
    func showSlots() {
        tableView.reloadData()
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
    }
}

// MARK: - objc methods

private extension SubjectDetailViewController {
    @objc func didTapAddSlot() {
        let alert = UIAlertController(title: "Новый слот", message: "\n\n\n\n\n\n", preferredStyle: .alert)

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame = CGRect(x: 0, y: 20, width: 270, height: 160)

        alert.view.addSubview(datePicker)

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { [weak self] _ in
            let selectedDate = datePicker.date
            self?.presenter.addSlot(date: selectedDate)
        }))

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SubjectDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.subject.slots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        let timestamp = presenter.subject.slots[indexPath.row]
        let date = timestamp.dateValue()

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        cell.textLabel?.text = formatter.string(from: date)
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont(name: Fonts.ubuntuRegular, size: 18)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteSlot(at: indexPath.row)
        }
    }
}

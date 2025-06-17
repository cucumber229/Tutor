//
//  SubjectsEditorViewController.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import Foundation
import FirebaseFirestore
import UIKit

protocol SubjectsEditorViewControllerProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showSubjects()
    func showError(message: String)
}

final class SubjectsEditorViewController: UIViewController {
    
    // MARK: UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SlotTableViewCell.self, forCellReuseIdentifier: "\(SlotTableViewCell.self)")
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
    var presenter: SubjectsEditorPresenterProtocol!
    
    override func viewDidLoad() {
        setupUI()
        presenter.loadAvailableSlots()
        super.viewDidLoad()
    }
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadAvailableSlots()
    }
}

// MARK: - Private methods

private extension SubjectsEditorViewController {
    func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        configureNavigationBar()
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
    
    func configureNavigationBar() {
        title = "Предметы"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddSubject)
        )
    }
    
    @objc private func didTapAddSubject() {
        let alert = UIAlertController(title: "Новый предмет", message: "Введите название", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Например, Математика"
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            self?.presenter.addSubject(named: name)
        }))
        present(alert, animated: true)
    }
}

// MARK: - SubjectsEditorViewControllerProtocol

extension SubjectsEditorViewController: SubjectsEditorViewControllerProtocol {
    func showSubjects() {
        tableView.reloadData()
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SubjectsEditorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.subjectGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(SlotTableViewCell.self)"
        ) as? SlotTableViewCell
        else {
            fatalError("Couldn't register cell")
        }
        
        let subject = presenter.subjectGroups[indexPath.row]
        
        cell.configure(subject: subject.name, slots: subject.slots)
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.showSubjectDetail(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteSubject(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

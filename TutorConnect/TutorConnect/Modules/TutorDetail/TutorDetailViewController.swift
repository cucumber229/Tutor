//
//  TutorDetailViewController.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import UIKit
import SnapKit
import Foundation

protocol TutorDetailViewControllerProtocol: AnyObject {
    func configureView(with tutor: TutorModel)
    func showLoading()
    func hideLoading()
    func showAlert(withTitle title: String)
}

final class TutorDetailViewController: UIViewController {
    
    private var selectedSubject: String?
    private var selectedSlot: Date?
    private var currentTutor: TutorModel?
    
    // MARK: UI
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Fonts.ubuntuBold, size: 18)
        label.textColor = .black
        return label
    }()
    
    private lazy var aboutLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Fonts.ubuntuRegular, size: 14)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private lazy var subjectsLabel: UILabel = {
        let label = UILabel()
        label.text = "Преподаваемые дисциплины:"
        label.font = UIFont(name: Fonts.ubuntuBold, size: 16)
        return label
    }()
    
    private lazy var bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Записаться на занятие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.ubuntuBold, size: 16)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        button.addTarget(self, action: #selector(bookLesson), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var availableSlotsView = AvailableSlotsView()
    
    private lazy var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            aboutLabel,
            subjectsLabel,
            availableSlotsView
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: MVP Properties
    var presenter: TutorDetailPresenter!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        setupUI()
        presenter.viewDidLoad()
        super.viewDidLoad()
    }
}

// MARK: - TutorDetailViewControllerProtocol

extension TutorDetailViewController: TutorDetailViewControllerProtocol {
    func configureView(with tutor: TutorModel) {
        currentTutor = tutor
        nameLabel.text = tutor.name
        aboutLabel.text = tutor.about
        availableSlotsView.configure(with: tutor.availableSlots ?? [:])

        availableSlotsView.onSlotSelected = { [weak self] subject, slot in
            guard let self = self else { return }

            self.selectedSubject = subject
            self.selectedSlot = slot

            self.bookButton.isHidden = false
        }
    }
    
    func showLoading() {
        loader.startAnimating()
        descriptionStackView.isHidden = true
        bookButton.isHidden = true
    }

    func hideLoading() {
        loader.stopAnimating()
        descriptionStackView.isHidden = false
    }
    
    func showAlert(withTitle title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

private extension TutorDetailViewController {
    func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        makeConstraints()
    }
    
    func addSubviews() {
        view.addSubview(descriptionStackView)
        view.addSubview(bookButton)
        view.addSubview(loader)
    }
    
    func makeConstraints() {
        descriptionStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(20)
            $0.right.equalTo(view.safeAreaLayoutGuide.snp.right).inset(20)
        }
        
        bookButton.snp.makeConstraints {
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(20)
            $0.right.equalTo(view.safeAreaLayoutGuide.snp.right).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        
        loader.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    @objc private func bookLesson() {
        guard
            let subject = selectedSubject,
            let time = selectedSlot,
            let tutorName = nameLabel.text
        else { return }

        presenter.bookSlot(subject: subject, time: time, tutorName: tutorName)
        bookButton.isHidden = true
    }
}

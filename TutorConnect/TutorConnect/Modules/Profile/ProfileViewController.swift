//
//  ProfileViewController.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 13.06.2025.
//

import Foundation
import UIKit
import SnapKit

protocol ProfileViewControllerProtocol: AnyObject {
    func setUserProfile(_ tutor: TutorModel)
    func showAlert(with title: String, with message: String)
}

final class ProfileViewController: UIViewController {
    
    // Properties
    private var isTutor: Bool {
        return modeSwitcher.selectedSegmentIndex == 1
    }
    
    //MARK: UI
    
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.greetingLabel
        label.font = UIFont(name: Fonts.ubuntuBold, size: 20)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 22
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.clipsToBounds = false
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        textField.snp.makeConstraints { $0.height.equalTo(Constants.textFieldHeight) }
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 22
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.clipsToBounds = false
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        textField.snp.makeConstraints { $0.height.equalTo(Constants.textFieldHeight) }
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var aboutTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: Fonts.ubuntuRegular, size: 14)
        textView.textColor = .black
        textView.backgroundColor = .white

        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true

        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.lineFragmentPadding = 0

        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = false
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOpacity = 0.1
        textView.layer.shadowRadius = 4
        textView.layer.shadowOffset = .zero

        textView.snp.makeConstraints { $0.height.equalTo(180) }
        return textView
    }()
    
    private lazy var modeSwitcher: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Ученик", "Репетитор"])
        control.selectedSegmentIndex = 1
        control.addTarget(self, action: #selector(authModeChanged(_:)), for: .valueChanged)
        control.backgroundColor = .clear
        control.selectedSegmentTintColor = UIColor.systemBlue
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        return control
    }()
    
    private lazy var updateButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.continueTitleButton, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addLessonsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить занятия", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(addLessonsTapped), for: .touchUpInside)
        button.snp.makeConstraints { $0.height.equalTo(Constants.buttonHeight) }
        return button
    }()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    // MARK: MVP Properties
    
    var presenter: ProfilePresenterProtocol!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.fetchFullTutorProfile()
        setupUI()
        setupDismissKeyboardGesture()
        updateVisibilityForRole()
    }
}

// MARK: - Public methods

extension ProfileViewController: ProfileViewControllerProtocol {
    func setUserProfile(_ tutor: TutorModel) {
        nameTextField.text = tutor.name
        priceTextField.text = "\(tutor.pricePerHour)"
        aboutTextView.text = tutor.about ?? ""
        validateInputs()
        
    }
    
    func showAlert(with title: String, with message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}


// MARK: - Private methods

private extension ProfileViewController {
    func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(modeSwitcher)
        contentStack.addArrangedSubview(greetingLabel)
        contentStack.addArrangedSubview(nameTextField)
        contentStack.addArrangedSubview(priceTextField)
        contentStack.addArrangedSubview(aboutTextView)
        contentStack.addArrangedSubview(addLessonsButton)

        view.addSubview(updateButton)
    }
    
    func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalToSuperview().inset(20)
        }
                
        updateButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.buttonHorizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.height.equalTo(Constants.buttonHeight)
        }
    }
    
    func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func validateInputs() {
        let nameValid = !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let aboutValid = !aboutTextView.text.trimmingCharacters(in: .whitespaces).isEmpty

        var isFormValid = nameValid && aboutValid

        if isTutor {
            let priceValid = Int(priceTextField.text ?? "") != nil
            isFormValid = isFormValid && priceValid
        }

        updateButton.isEnabled = isFormValid
        updateButton.alpha = isFormValid ? 1.0 : 0.5
    }
    
    func updateVisibilityForRole() {
        priceTextField.isHidden = !isTutor
        addLessonsButton.isHidden = !isTutor
    }
}


// MARK: - objc methods

private extension ProfileViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func saveButtonTapped() {
        let nameToSave = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let aboutToSave = aboutTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nameToSave.isEmpty, !aboutToSave.isEmpty else { return }

        var priceToSave = 0
        if isTutor {
            guard let raw = priceTextField.text,
                  let parsed = Int(raw), parsed > 0 else { return }
            priceToSave = parsed
        }

        presenter.updateTutorProfile(
            name: nameToSave,
            price: priceToSave,
            about: aboutToSave,
            isTutor: isTutor
        )
    }
    
    @objc private func textFieldDidChange() {
        validateInputs()
    }
    
    @objc private func addLessonsTapped() {
        presenter.showSubjects()
    }
    
    @objc private func authModeChanged(_ sender: UISegmentedControl) {
        updateVisibilityForRole()
        validateInputs()
    }
}

// MARK: - Constants

private extension ProfileViewController {
    enum Constants {
        static let textFieldHeight: CGFloat = 48
        static let buttonHeight: CGFloat = 50
        static let buttonHorizontalInset: CGFloat = 20
        
        static let defaultPlaceholder: String = "*Пожалуйста, представьтесь*"
        static let continueTitleButton: String = "Обновить"
        static let greetingLabel: String = "Здравствуйте!"
    }
}

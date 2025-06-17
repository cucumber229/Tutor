//
//  ProfileViewController.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 13.06.2025.
//




import Foundation
import UIKit
import SnapKit

protocol ProfileViewControllerProtocol: AnyObject {
    func setUserProfile(_ tutor: TutorModel)
    func showAlert(with title: String, with message: String)
}

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var isTutor: Bool {
        modeSwitcher.selectedSegmentIndex == 1
    }
    
    // MARK: - UI Elements
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.greetingLabel
        label.font = UIFont(name: Fonts.ubuntuBold, size: 20)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var modeSwitcher: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Ученик", "Репетитор"])
        control.selectedSegmentIndex = 1
        control.addTarget(self, action: #selector(authModeChanged(_:)), for: .valueChanged)
        control.backgroundColor = .clear
        control.selectedSegmentTintColor = .systemBlue
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        control.snp.makeConstraints { $0.height.equalTo(40) }
        return control
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.namePlaceholder
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 22
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = .zero
        textField.snp.makeConstraints { $0.height.equalTo(Constants.textFieldHeight) }
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Цена за час"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.pricePlaceholder
        textField.keyboardType = .numberPad
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 22
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = .zero
        textField.snp.makeConstraints { $0.height.equalTo(Constants.textFieldHeight) }
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "О себе"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var aboutTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: Fonts.ubuntuRegular, size: 14)
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOpacity = 0.1
        textView.layer.shadowRadius = 4
        textView.layer.shadowOffset = .zero
        textView.snp.makeConstraints { $0.height.equalTo(180) }
        return textView
    }()
    
    private lazy var addLessonsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить занятия", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(addLessonsTapped), for: .touchUpInside)
        button.snp.makeConstraints { $0.height.equalTo(Constants.buttonHeight) }
        return button
    }()
    
    private lazy var updateButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.continueTitleButton, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var logoutButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Выход", style: .plain, target: self, action: #selector(logoutTapped))
    }()
    
    // MARK: - Presenter
    var presenter: ProfilePresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.fetchFullTutorProfile()
        setupUI()
        setupDismissKeyboardGesture()
        updateVisibilityForRole()
        navigationItem.rightBarButtonItem = logoutButton
    }
}

// MARK: - ProfileViewControllerProtocol
extension ProfileViewController: ProfileViewControllerProtocol {
    func setUserProfile(_ tutor: TutorModel) {
        nameTextField.text = tutor.name
        priceTextField.text = "\(tutor.pricePerHour)"
        aboutTextView.text = tutor.about ?? ""
        validateInputs()
    }
    
    func showAlert(with title: String, with message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Private setup & validation
private extension ProfileViewController {
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        [modeSwitcher, greetingLabel,
         nameLabel, nameTextField,
         priceLabel, priceTextField,
         aboutLabel, aboutTextView,
         addLessonsButton].forEach { contentStack.addArrangedSubview($0) }
        view.addSubview(updateButton)
        updateButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.buttonHorizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.height.equalTo(Constants.buttonHeight)
        }
    }
    
    func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func validateInputs() {
        let nameValid = !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let aboutValid = !aboutTextView.text.trimmingCharacters(in: .whitespaces).isEmpty
        var formReady = nameValid && aboutValid
        if isTutor {
            let priceValid = (Int(priceTextField.text ?? "") ?? 0) > 0
            formReady = formReady && priceValid
        }
        updateButton.isEnabled = formReady
        updateButton.alpha = formReady ? 1 : 0.5
    }
    
    func updateVisibilityForRole() {
        priceLabel.isHidden = !isTutor
        priceTextField.isHidden = !isTutor
        addLessonsButton.isHidden = !isTutor
    }
}

// MARK: - Actions
private extension ProfileViewController {
    @objc func dismissKeyboard() { view.endEditing(true) }
    @objc func saveButtonTapped() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let about = aboutTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !about.isEmpty else { return }
        var price = 0
        if isTutor {
            guard let val = Int(priceTextField.text ?? ""), val > 0 else { return }
            price = val
        }
        presenter.updateTutorProfile(name: name, price: price, about: about, isTutor: isTutor)
    }
    @objc func textFieldDidChange() { validateInputs() }
    @objc func addLessonsTapped() { presenter.showSubjects() }
    @objc func authModeChanged(_ sender: UISegmentedControl) {
        updateVisibilityForRole()
        validateInputs()
    }
    @objc func logoutTapped() { presenter.signOut() }
}

// MARK: - Constants
private extension ProfileViewController {
    enum Constants {
        static let textFieldHeight: CGFloat = 48
        static let buttonHeight: CGFloat = 50
        static let buttonHorizontalInset: CGFloat = 20
        static let namePlaceholder = "Введите ваше имя"
        static let pricePlaceholder = "Например: 500"
        static let continueTitleButton = "Обновить"
        static let greetingLabel = "Здравствуйте!"
    }
}

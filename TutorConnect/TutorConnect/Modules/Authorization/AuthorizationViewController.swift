//
//  AuthorizationViewController.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 13.06.2025.
//

import Foundation
import UIKit
import SnapKit

protocol AuthorizationViewProtocol: AnyObject {
    func showError(message: String)
}

final class AuthorizationViewController: UIViewController, AuthorizationViewProtocol {
    
    private enum AuthMode {
        case signIn
        case signUp
    }
        
    private var currentMode: AuthMode = .signIn {
        didSet {
            updateUIForCurrentMode()
        }
    }
    
    // MARK: - UI
    
    private lazy var emailLabel = makeLabel(withTextKey: "Ваш Email")
    private lazy var emailTextField = makeTextField(placeholderKey: "Введите адрес эл.почты")
    
    private lazy var passwordLabel = makeLabel(withTextKey: "Пароль")
    private lazy var passwordTextField = makeTextField(placeholderKey: "Введите пароль", isSecure: true)
    
    private lazy var modeSwitcher: UISegmentedControl = {
        let control = UISegmentedControl(
            items: [Constants.signInTitle, Constants.signUpTitle]
        )
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(authModeChanged(_:)), for: .valueChanged)
        control.backgroundColor = .clear
        control.selectedSegmentTintColor = UIColor.blueButton
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.blueButton], for: .normal)
        return control
    }()
    
    private lazy var authorizeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 25
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.blueButton
        button.setTitle(Constants.signInTitle, for: .normal)
        button.addTarget(self, action: #selector(authorizeButtonPressed), for: .touchUpInside)
        button.snp.makeConstraints { $0.height.equalTo(50) }
        return button
    }()
    
    private lazy var formStack: UIStackView = {
        let emailStack = makeFormStack(label: emailLabel, textField: emailTextField)
        let passwordStack = makeFormStack(label: passwordLabel, textField: passwordTextField)

        let stack = UIStackView(arrangedSubviews: [modeSwitcher, emailStack, passwordStack, authorizeButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.layoutMargins = UIEdgeInsets(
            top: 0,
            left: Constants.stackHorizontalInset,
            bottom: 0,
            right: Constants.stackHorizontalInset
        )
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    // MARK: - MVP
    
    var presenter: AuthorizationPresenterProtocol!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDismissKeyboardGesture()
    }
}

// MARK: @objc methods
private extension AuthorizationViewController {
    @objc func authorizeButtonPressed() {
        dismissKeyboard()

        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Введите email.")
            return
        }

        guard isValidEmail(email) else {
            showAlert(message: "Неверный формат email.")
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Введите пароль.")
            return
        }

        switch currentMode {
        case .signIn:
            presenter.signIn(email: email, password: password)
        case .signUp:
            presenter.signUp(email: email, password: password)
        }
    }
    
    @objc private func authModeChanged(_ sender: UISegmentedControl) {
        currentMode = sender.selectedSegmentIndex == 0 ? .signIn : .signUp
        resetInputFields()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Public methods

extension AuthorizationViewController {
    func showError(message: String) {
        showAlert(message: message)
    }
}

// MARK: - Private Methods

private extension AuthorizationViewController {
    func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
    }
    
    func addSubviews() {
        view.addSubview(formStack)
        view.addSubview(authorizeButton)
    }
    
    func setupConstraints() {
        formStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        authorizeButton.snp.makeConstraints {
            $0.top.equalTo(formStack.snp.bottom).offset(Constants.buttonTopSpacing)
            $0.left.right.equalToSuperview().inset(Constants.buttonHorizontalInset)
            $0.height.equalTo(Constants.buttonHeight)
        }
    }

    func makeLabel(withTextKey key: String) -> UILabel {
        let label = UILabel()
        label.text = key
        label.font = UIFont(name: Fonts.ubuntuRegular, size: 14)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }

    func makeTextField(placeholderKey: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholderKey
        textField.isSecureTextEntry = isSecure
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 22
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.clipsToBounds = false
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        textField.snp.makeConstraints { $0.height.equalTo(Constants.textFieldHeight) }
        return textField
    }

    func makeFormStack(label: UILabel, textField: UITextField) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [label, textField])
        stack.axis = .vertical
        stack.spacing = Constants.stackBaseSpacing
        return stack
    }
    
    func updateUIForCurrentMode() {
        switch currentMode {
        case .signIn:
            authorizeButton.setTitle(Constants.signInTitle, for: .normal)
        case .signUp:
            authorizeButton.setTitle(Constants.signUpTitle, for: .normal)
        }
    }
    
    func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", Constants.emailRegEx).evaluate(with: email)
    }
    
    func showAlert(title: String = Constants.aletrTitle, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    func resetInputFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}

private extension AuthorizationViewController {
    enum Constants {
        static let textFieldHeight: CGFloat = 48
        
        static let stackHorizontalInset: CGFloat = 20
        static let stackBaseSpacing: CGFloat = 10
        
        static let buttonHorizontalInset: CGFloat = 20
        static let buttonHeight: CGFloat = 50
        static let buttonTopSpacing: CGFloat = 50
        
        static let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        static let aletrTitle: String = "Ошибка"
        
        static let signInTitle: String = "Войти"
        static let signUpTitle: String = "Зарегистрироваться"
    }
}

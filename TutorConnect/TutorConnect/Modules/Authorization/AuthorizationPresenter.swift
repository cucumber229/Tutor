//
//  AuthorizationPresenter.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 13.06.2025.
//

import Foundation

protocol AuthorizationPresenterProtocol: AnyObject {
    func signIn(email: String, password: String)
    func signUp(email: String, password: String)
}

final class AuthorizationPresenter {
    // Properties
    private let moduleOutput: AuthorizationCoordinatorProtocol
    private weak var view: AuthorizationViewProtocol?
    
    // Dependencies
    private let firebaseService: FirebaseAuthServiceProtocol = FirebaseAuthService()
    
    // MARK: - Initialization
    
    init(_ moduleOutput: AuthorizationCoordinatorProtocol, view: AuthorizationViewProtocol) {
        self.moduleOutput = moduleOutput
        self.view = view
    }
}

// MARK: - AuthorizationPresenterProtocol

extension AuthorizationPresenter: AuthorizationPresenterProtocol {
    func signIn(email: String, password: String) {
        firebaseService.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.moduleOutput.didAuthorize()
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
        firebaseService.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.moduleOutput.didAuthorize()
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
}

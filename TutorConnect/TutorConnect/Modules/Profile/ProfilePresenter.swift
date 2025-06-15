//
//  ProfilePresenter.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 13.06.2025.
//

import Foundation
import FirebaseAuth

protocol ProfilePresenterProtocol: AnyObject {
    func fetchFullTutorProfile()
    func updateTutorProfile(name: String, price: Int, about: String, isTutor: Bool)
    func showSubjects()
}

final class ProfilePresenter {
    // Properties
    private let moduleOutput: ProfileCoordinatorProtocol
    private let profileService: FirebaseProfileServiceProtocol = FirebaseProfileService()
    private weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Initialization
    
    init(_ moduleOutput: ProfileCoordinatorProtocol, view: ProfileViewControllerProtocol) {
        self.moduleOutput = moduleOutput
        self.view = view
    }
}

// MARK: - Public methods
extension ProfilePresenter: ProfilePresenterProtocol {
    func fetchFullTutorProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            view?.showAlert(with: "Ошибка", with: "Пользователь не авторизован")
            return
        }

        profileService.fetchTutor(by: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tutor):
                    self?.view?.setUserProfile(tutor)
                case .failure(let error):
                    self?.view?.showAlert(with: "Ошибка", with: "\(error)")
                }
            }
        }
    }

    func updateTutorProfile(name: String, price: Int, about: String, isTutor: Bool) {
        profileService.updateTutorProfile(name: name, price: price, about: about, isTutor: isTutor) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success:
                    self?.view?.showAlert(with: "Профиль успешно обновлен!", with: "")
                case .failure(let error):
                    self?.view?.showAlert(with: "Ошибка", with: "\(error)")
                }
            }
        }
    }
    
    func showSubjects() {
        moduleOutput.goToSubjectsList()
    }
}

//
//  ProfilePresenter.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 13.06.2025.
//

import Foundation
import FirebaseAuth

protocol ProfilePresenterProtocol: AnyObject {
    func fetchFullTutorProfile()
    func updateTutorProfile(name: String, price: Int, about: String, isTutor: Bool)
    func showSubjects()
    func signOut()
}

final class ProfilePresenter {
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
                case .failure(_):
                    print("Error")
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

    func signOut() {
        profileService.signOut { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let bundleID = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: bundleID)
                    }

                    self?.moduleOutput.didLogOut()

                case .failure(let error):
                    self?.view?.showAlert(with: "Ошибка", with: "\(error.localizedDescription)")
                }
            }
        }
    }
}

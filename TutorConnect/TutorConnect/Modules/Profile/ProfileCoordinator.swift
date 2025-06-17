//
//  ProfileCoordinator.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 13.06.2025.
//

import UIKit

protocol ProfileCoordinatorProtocol: Coordinator {
    func goToSubjectsList()
    func didLogOut()
}

final class ProfileCoordinator {
    
    private var navigationController = UINavigationController()
    private var applicationCoordinator: AppCoordinator?
    
    // MARK: - Initialization
    
    init(applicationCoordinator: AppCoordinator) {
        self.applicationCoordinator = applicationCoordinator
        
        let controller = ProfileViewController()
        let presenter = ProfilePresenter(self, view: controller)
        controller.presenter = presenter
        
        self.navigationController = UINavigationController(rootViewController: controller)
    }
}

extension ProfileCoordinator: ProfileCoordinatorProtocol {
    func start() -> UIViewController {
        return navigationController
    }

    func goToSubjectsList() {
        let coordinator = SubjectsEditorCoordinator(navigationController: navigationController)
        coordinator.start()
    }

    func didLogOut() {
        applicationCoordinator?.goToAuthorization()
    }
}

//
//  AuthorizationCoordinator.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 13.06.2025.
//

import UIKit

protocol AuthorizationCoordinatorProtocol: Coordinator {
    func didAuthorize()
}

final class AuthorizationCoordinator: AuthorizationCoordinatorProtocol {
    
    // Properties
    private var navigationController = UINavigationController()
    private var applicationCoordinator: AppCoordinator?
    
    // MARK: - Initialization
    
    init(applicationCoordinator: AppCoordinator) {
        self.applicationCoordinator = applicationCoordinator
        
        let controller = AuthorizationViewController()
        let presenter = AuthorizationPresenter(self, view: controller)
        controller.presenter = presenter
        
        self.navigationController = UINavigationController(rootViewController: controller)
    }
    
    func start() -> UIViewController {
        return navigationController
    }
    
    func didAuthorize() {
        applicationCoordinator?.goToProfile()
    }
}

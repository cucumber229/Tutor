//
//  AppCoordinator.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 13.06.2025.
//

import UIKit

final class AppCoordinator {
    
    // Properties
    private var window: UIWindow
    
    // MARK: - Initialization
    
    init(window: UIWindow) {
        self.window = window
    }
    
    // Dependencies
    private lazy var authorizationCoordinator: AuthorizationCoordinatorProtocol = {
        let coordinator = AuthorizationCoordinator(applicationCoordinator: self)
        return coordinator
    }()
    
    private lazy var tabBarCoordinator: TabBarCoordinatorProtocol = {
        let tabBarCoordinator = TabBarCooridnator(applicationCoordinator: self)
        return tabBarCoordinator
    }()
}

// MARK: - Public methods

extension AppCoordinator {
    func start() {
        setRootViewController(authorizationCoordinator.start())
    }
    
    func goToProfile() {
        setRootViewController(tabBarCoordinator.start())
    }
    
    func goToMainPage() {
        setRootViewController(tabBarCoordinator.start())
    }
}

// MARK: - Private metohds

private extension AppCoordinator {
    func setRootViewController( _ viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}

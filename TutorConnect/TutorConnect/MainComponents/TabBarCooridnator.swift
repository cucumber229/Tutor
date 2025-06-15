//
//  TabBarCooridnator.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import UIKit

protocol TabBarCoordinatorProtocol: Coordinator {
    
}

final class TabBarCooridnator: TabBarCoordinatorProtocol {
    
    // Properties
    weak var tabBarController: UITabBarController?
    private lazy var navigationCoordinator = UINavigationController()
    private var applicationCoordinator: AppCoordinator
    
    init(applicationCoordinator: AppCoordinator) {
        self.applicationCoordinator = applicationCoordinator
    }
        
    func start() -> UIViewController {
        let tabBarController = UITabBarController()
        self.tabBarController = tabBarController
        tabBarController.viewControllers = [
            showProfilePage(),
            showMainPage(),
            showMyBookingsPage()
        ]
        return tabBarController
    }
}

// MARK: - Private methods

private extension TabBarCooridnator {
    private func showMainPage() -> UIViewController {
        let coordinator = TutorListCoordinator(tabBarcoordinator: self)
        let controller = coordinator.start()
        controller.tabBarItem = .init(
            title: "Профиль",
            image: .init(systemName: "house"),
            selectedImage: .init(systemName: "house.fill")
        )
        return controller
    }
    
    private func showProfilePage() -> UIViewController {
        let coordinator = ProfileCoordinator(applicationCoordinator: applicationCoordinator)
        let controller = coordinator.start()
        controller.tabBarItem = .init(
            title: "Преподаватели",
            image: .init(systemName: "person.circle"),
            selectedImage: .init(systemName: "person.circle.fill")
        )
        return controller
    }
    
    private func showMyBookingsPage() -> UIViewController {
        let coordinator = MyBookingsCoordinator(applicationCoordinator: applicationCoordinator)
        let controller = coordinator.start()
        controller.tabBarItem = .init(
            title: "Занятия",
            image: .init(systemName: "calendar"),
            selectedImage: .init(systemName: "calendar.fill")
        )
        return controller
    }
}

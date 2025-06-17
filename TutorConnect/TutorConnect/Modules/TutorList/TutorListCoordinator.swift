//
//  TutorListCoordinator.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import UIKit

protocol TutorListCoordinatorProtocol: Coordinator {
    func goToTutorDetail(tutor: TutorModel)
}

final class TutorListCoordinator {
    
    private var navigationController = UINavigationController()
    private var tabBarcoordinator: TabBarCoordinatorProtocol?
    
    init(tabBarcoordinator: TabBarCoordinatorProtocol) {
        self.tabBarcoordinator = tabBarcoordinator
        
        let controller = TutorListViewController()
        let presenter = TutorListPresenter(self, view: controller)
        controller.presenter = presenter
        self.navigationController = UINavigationController(rootViewController: controller)
    }
}

// MARK: - TutorListCoordinatorProtocol

extension TutorListCoordinator: TutorListCoordinatorProtocol {
    func start() -> UIViewController {
        return navigationController
    }
    
    func goToTutorDetail(tutor: TutorModel) {
        let controller = TutorDetailViewController()
        let presenter = TutorDetailPresenter(view: controller, tutor: tutor)
        controller.presenter = presenter
        navigationController.pushViewController(controller, animated: true)
    }
}

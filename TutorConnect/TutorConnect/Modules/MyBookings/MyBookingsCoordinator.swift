//
//  MyBookingsCoordinator.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 15.06.2025.
//

import Foundation
import UIKit

protocol MyBookingsCoordinatorProtocol: Coordinator {
    
}

final class MyBookingsCoordinator {
    
    private var navigationController = UINavigationController()
    private var applicationCoordinator: AppCoordinator?
    
    // MARK: - Initialization
    init(applicationCoordinator: AppCoordinator) {
        self.applicationCoordinator = applicationCoordinator
        
        let controller = MyBookingsViewController()
        let presenter = MyBookingsPresenter(view: controller, moduleOutput: self)
        controller.presenter = presenter
        
        self.navigationController = UINavigationController(rootViewController: controller)
    }
}

extension MyBookingsCoordinator: MyBookingsCoordinatorProtocol {
    func start() -> UIViewController {
        return navigationController
    }
}

//
//  SubjectsEditorCoordinator.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import Foundation
import UIKit

protocol SubjectsEditorCoordinatorProtocol: Coordinator {
    func showSlotDetail(subject: SubjectSlotGroup)
}

final class SubjectsEditorCoordinator: SubjectsEditorCoordinatorProtocol {
    // Properties
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        let controller = SubjectsEditorViewController()
        let presenter = SubjectsEditorPresenter(view: controller, moduleOutput: self)
        controller.presenter = presenter
        navigationController.pushViewController(controller, animated: true)
    }
    
    func start() -> UIViewController {
        return navigationController
    }
    
    func showSlotDetail(subject: SubjectSlotGroup) {
        let controller = SubjectDetailViewController()
        let presenter = SubjectDetailPresenter(view: controller, subject: subject)
        controller.presenter = presenter
        navigationController.pushViewController(controller, animated: true)
    }
}

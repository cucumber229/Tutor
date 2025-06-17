//
//  TutorListPresenter.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import Foundation

protocol TutorListPresenterProtocol: AnyObject {
    func loadTutors()
    func showTutorDetail(indexPath: IndexPath)
    var tutors: [TutorModel] { get }
}

final class TutorListPresenter {
    private let moduleOutput: TutorListCoordinatorProtocol
    private weak var view: TutorListViewControllerProtocol?
    private let tutorService: FirebaseTutorServiceProtocol = FirebaseTutorService()
    
    private(set) var tutors: [TutorModel] = []
    
    // MARK: - Initialization
    init(_ moduleOutput: TutorListCoordinatorProtocol, view: TutorListViewControllerProtocol) {
        self.moduleOutput = moduleOutput
        self.view = view
    }
}

// MARK: - Public methods

extension TutorListPresenter: TutorListPresenterProtocol {
    func loadTutors() {
        view?.showLoading()
        
        tutorService.fetchTutors { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                switch result {
                case .success(var tutors):
                    let currentUserID = UserDefaults.standard.string(forKey: "uid")
                    if let uid = currentUserID {
                        tutors.removeAll { $0.uid == uid }
                    }
                    self?.tutors = tutors
                    self?.view?.showTutors()
                    
                case .failure(_):
                    print("Error")
                }
            }
        }
    }
    
    func showTutorDetail(indexPath: IndexPath) {
        moduleOutput.goToTutorDetail(tutor: tutors[indexPath.row])
    }
}

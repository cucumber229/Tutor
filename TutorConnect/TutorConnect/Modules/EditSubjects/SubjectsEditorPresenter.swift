//
//  SubjectsEditorPresenter.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 14.06.2025.
//

import Foundation
import FirebaseFirestore

protocol SubjectsEditorPresenterProtocol: AnyObject {
    func loadAvailableSlots()
    func showSubjectDetail(at index: Int)
    func addSubject(named name: String)
    func deleteSubject(at index: Int)
    var subjectGroups: [SubjectSlotGroup] { get }
}

final class SubjectsEditorPresenter {
    private weak var view: SubjectsEditorViewControllerProtocol?
    private let moduleOutput: SubjectsEditorCoordinatorProtocol
    private let slotsService: FirebaseSlotsServiceProtocol = FirebaseSlotsService()
    
    private(set) var subjectGroups: [SubjectSlotGroup] = []
    
    init(view: SubjectsEditorViewControllerProtocol, moduleOutput: SubjectsEditorCoordinatorProtocol) {
        self.view = view
        self.moduleOutput = moduleOutput
    }
}

extension SubjectsEditorPresenter: SubjectsEditorPresenterProtocol {
    func loadAvailableSlots() {
        view?.showLoading()
        
        slotsService.fetchCurrentTutorSlots { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                switch result {
                case .success(let fetchedSlots):
                    self?.subjectGroups = fetchedSlots
                    self?.view?.showSubjects()
                    print(fetchedSlots)
                case .failure(let error):
                    print("Ошибка получения слотов: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addSubject(named name: String) {
        let newGroup = SubjectSlotGroup(name: name)
        subjectGroups.append(newGroup)

        slotsService.addSubject(name: name) { result in
            switch result {
            case .success:
                self.view?.showSubjects()
                print("Предмет добавлен в Firebase: \(name)")
            case .failure(let error):
                print("Ошибка при добавлении: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteSubject(at index: Int) {
        let name = subjectGroups[index].name
        subjectGroups.remove(at: index)
        view?.showSubjects()

        slotsService.deleteSubject(name: name) { result in
            switch result {
            case .success:
                print("Удалено: \(name)")
            case .failure(let error):
                print("Ошибка при удалении: \(error.localizedDescription)")
            }
        }
    }
    
    func showSubjectDetail(at index: Int) {
        moduleOutput.showSlotDetail(subject: subjectGroups[index])
    }
}

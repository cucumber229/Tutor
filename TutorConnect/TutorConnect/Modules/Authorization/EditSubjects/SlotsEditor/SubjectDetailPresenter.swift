//
//  SubjectDetailPresenterProtocol.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import Foundation
import FirebaseCore

protocol SubjectDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func addSlot(date: Date)
    func deleteSlot(at index: Int)
    var subject: SubjectSlotGroup { get }
}

final class SubjectDetailPresenter {
    private weak var view: SubjectDetailViewControllerProtocol?
    private let slotsService: FirebaseSlotsServiceProtocol = FirebaseSlotsService()
    
    private(set) var subject: SubjectSlotGroup
    
    init(view: SubjectDetailViewControllerProtocol, subject: SubjectSlotGroup) {
        self.view = view
        self.subject = subject
    }
}

extension SubjectDetailPresenter: SubjectDetailPresenterProtocol {
    func viewDidLoad() {
        view?.showLoading()
        slotsService.fetchCurrentTutorSlots { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                switch result {
                case .success(let groups):
                    guard let group = groups.first(where: { $0.name == self?.subject.name }) else {
                        self?.view?.showError(message: "Предмет не найден")
                        return
                    }
                    self?.subject = group
                    self?.view?.showSlots()
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func addSlot(date: Date) {
        slotsService.addSlot(for: subject.name, date: date) { [weak self] result in
            switch result {
            case .success:
                let timestamp = Timestamp(date: date)
                DispatchQueue.main.async {
                    self?.subject.slots.append(timestamp)
                    self?.subject.slots.sort { $0.dateValue() < $1.dateValue() }
                    self?.view?.showSlots()
                }
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }

    func deleteSlot(at index: Int) {
        guard index < subject.slots.count else { return }
        let timestamp = subject.slots[index]

        slotsService.deleteSlot(for: subject.name, date: timestamp.dateValue()) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.subject.slots.remove(at: index)
                    self?.view?.showSlots()
                }
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
}

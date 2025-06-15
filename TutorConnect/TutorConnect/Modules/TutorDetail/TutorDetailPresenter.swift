//
//  TutorDetailPresenter.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import Foundation
import FirebaseFirestore

protocol TutorDetailPresenterProtocol: AnyObject {
    func bookSlot(subject: String, time: Date, tutorName: String)
    func viewDidLoad()
}

final class TutorDetailPresenter {
    // Dependencies
    private weak var view: TutorDetailViewControllerProtocol?
    private let bookingService: FirebaseBookingServiceProtocol = FirebaseBookingService()
    private let profileService: FirebaseProfileServiceProtocol = FirebaseProfileService()
    
    // Properties
    private var tutor: TutorModel
    
    // MARK: Initialization
    
    init(view: TutorDetailViewControllerProtocol, tutor: TutorModel) {
        self.view = view
        self.tutor = tutor
    }
}

// MARK: - TutorDetailPresenterProtocol

extension TutorDetailPresenter: TutorDetailPresenterProtocol {
    
    func viewDidLoad() {
        view?.showLoading()
        
        profileService.fetchTutor(by: tutor.uid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.view?.hideLoading()
                
                switch result {
                case .success(let updatedTutor):
                    self.tutor = updatedTutor
                    self.view?.configureView(with: updatedTutor)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func bookSlot(subject: String, time: Date, tutorName: String) {
        bookingService.bookSlot(forTutor: tutor.uid, tutorName: tutorName, subject: subject, time: time) { [weak self] result in
            switch result {
            case .success:
                self?.tutor.availableSlots?[subject]?.removeAll {
                    Calendar.current.compare($0.dateValue(), to: time, toGranularity: .minute) == .orderedSame
                }

                if let tutor = self?.tutor {
                    self?.view?.configureView(with: tutor)
                    self?.view?.showAlert(withTitle: "Вы успешно записались на занятие")
                }

            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
}

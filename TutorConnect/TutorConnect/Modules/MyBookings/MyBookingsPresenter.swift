//
//  MyBookingsPresenter.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 15.06.2025.
//

import Foundation

enum MyBookingsMode {
    case student
    case tutor
}

protocol MyBookingsPresenterProtocol: AnyObject {
    func viewDidLoad()
    var isTutor: Bool { get }
    var selectedMode: MyBookingsMode { get set }
    var currentBookings: [BookingInfo] { get }
}

final class MyBookingsPresenter {
    private weak var view: MyBookingsViewControllerProtocol?
    private let moduleOutput: MyBookingsCoordinatorProtocol
    private let bookingService: FirebaseBookingServiceProtocol = FirebaseBookingService()
    private let cacheService = BookingsCacheService()
    
    private(set) var isTutor: Bool = false
    private(set) var studentBookings: [BookingInfo] = []
    private(set) var tutorBookings: [BookingInfo] = []
    var selectedMode: MyBookingsMode = .student
    
    // MARK: Initialization
    
    init(view: MyBookingsViewControllerProtocol?, moduleOutput: MyBookingsCoordinatorProtocol) {
        self.view = view
        self.moduleOutput = moduleOutput
    }
}


extension MyBookingsPresenter: MyBookingsPresenterProtocol {
    var currentBookings: [BookingInfo] {
        return selectedMode == .student ? studentBookings : tutorBookings
    }
    
    func viewDidLoad() {
        view?.showLoading()
        bookingService.fetchFullBookingData { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let data):
                    self.cacheService.save(student: data.studentBookings, tutor: data.tutorBookings)
                    self.isTutor = data.isTutor
                    self.tutorBookings = data.tutorBookings
                    self.studentBookings = data.studentBookings
                    self.selectedMode = data.isTutor ? .tutor : .student
                    self.view?.hideLoading()
                    self.view?.showBookings()
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                    if let cached = self.cacheService.load() {
                        self.isTutor = cached.isTutor
                        self.tutorBookings = cached.tutorBookings
                        self.studentBookings = cached.studentBookings
                        self.selectedMode = cached.isTutor ? .tutor : .student
                    } else {
                        self.isTutor = false
                        self.tutorBookings = []
                        self.studentBookings = []
                        self.selectedMode = .student
                    }
                    self.view?.hideLoading()
                    self.view?.showBookings()
                }
            }
        }
    }
}

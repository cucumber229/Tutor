//
//  FirebaseBookingService.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 14.06.2025.
//

import Foundation
import Firebase
import FirebaseAuth

protocol FirebaseBookingServiceProtocol: AnyObject {
    func bookSlot(forTutor tutorId: String, tutorName: String, subject: String, time: Date, completion: ((Result<Void, Error>) -> Void)?)
    func fetchFullBookingData(completion: @escaping (Result<FullBookingData, Error>) -> Void)
}

final class FirebaseBookingService: FirebaseBookingServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func bookSlot(forTutor tutorId: String,
                  tutorName: String,
                  subject: String,
                  time: Date,
                  completion: ((Result<Void, Error>) -> Void)? = nil) {

        guard let currentUser = Auth.auth().currentUser,
              let currentUserEmail = currentUser.email else {
            completion?(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"])))
            return
        }

        let db = Firestore.firestore()
        let timestamp = Timestamp(date: time)

        let tutorRef = db.collection("users").document(tutorId)
        let studentRef = db.collection("users").document(currentUser.uid)

        let slotInfoForTutor: [String: Any] = [
            "subject": subject,
            "email": currentUserEmail,
            "time": timestamp
        ]

        let slotInfoForStudent: [String: Any] = [
            "subject": subject,
            "time": timestamp,
            "tutorId": tutorId,
            "tutorName": tutorName
        ]

        let batch = db.batch()

        batch.updateData([
            "availableSlots.\(subject)": FieldValue.arrayRemove([timestamp]),
            "selectedSlots": FieldValue.arrayUnion([slotInfoForTutor])
        ], forDocument: tutorRef)

        batch.updateData([
            "userBookings": FieldValue.arrayUnion([slotInfoForStudent])
        ], forDocument: studentRef)

        batch.commit { error in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    func fetchFullBookingData(completion: @escaping (Result<FullBookingData, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401)))
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let isTutor = data["isTutor"] as? Bool else {
                completion(.failure(NSError(domain: "Parse", code: 0)))
                return
            }

            var tutorBookings: [BookingInfo] = []
            var studentBookings: [BookingInfo] = []

            if let selected = data["selectedSlots"] as? [[String: Any]] {
                tutorBookings = selected.compactMap { dict in
                    guard let subject = dict["subject"] as? String,
                          let email = dict["email"] as? String,
                          let time = dict["time"] as? Timestamp else { return nil }

                    return BookingInfo(subject: subject, time: time, email: email, tutorId: nil, tutorName: nil)
                }
            }

            if let userBookings = data["userBookings"] as? [[String: Any]] {
                studentBookings = userBookings.compactMap { dict in
                    guard let subject = dict["subject"] as? String,
                          let tutorId = dict["tutorId"] as? String,
                          let tutorName = dict["tutorName"] as? String,
                          let time = dict["time"] as? Timestamp else { return nil }

                    return BookingInfo(subject: subject, time: time, email: nil, tutorId: tutorId, tutorName: tutorName)
                }
            }

            let result = FullBookingData(
                isTutor: isTutor,
                tutorBookings: tutorBookings,
                studentBookings: studentBookings
            )

            completion(.success(result))
        }
    }
}

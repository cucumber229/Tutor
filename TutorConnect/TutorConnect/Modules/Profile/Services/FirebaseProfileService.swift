//
//  FirebaseProfileService.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 13.06.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol FirebaseProfileServiceProtocol {
    func updateTutorProfile(name: String, price: Int, about: String, isTutor: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchTutor(by uid: String, completion: @escaping (Result<TutorModel, Error>) -> Void)
    func signOut(completion: @escaping (Result<Void, Error>) -> Void)
}

final class FirebaseProfileService: FirebaseProfileServiceProtocol {
    private let db = Firestore.firestore()
    func updateTutorProfile(name: String, price: Int, about: String, isTutor: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Не авторизован"])))
            return
        }

        let updates: [String: Any] = [
            "name": name,
            "pricePerHour": price,
            "about": about,
            "isTutor": isTutor
        ]

        db.collection("users").document(uid).updateData(updates) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchTutor(by uid: String, completion: @escaping (Result<TutorModel, Error>) -> Void) {
        let docRef = db.collection("users").document(uid)

        docRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let isTutor = data["isTutor"] as? Bool,
                  let name = data["name"] as? String,
                  let email = data["email"] as? String,
                  let pricePerHour = data["pricePerHour"] as? Int,
                  let subjects = data["subjects"] as? [String]
            else {
                completion(.failure(NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить данные преподавателя"])))
                return
            }

            // Обрабатываем availableSlots
            var availableSlots: [String: [Timestamp]]? = nil
            if let raw = data["availableSlots"] as? [String: [Any]] {
                availableSlots = raw.mapValues { $0.compactMap { $0 as? Timestamp } }
            }

            // Обрабатываем selectedSlots
            var selectedSlots: [SelectedSlot]? = nil
            if let rawSelected = data["selectedSlots"] as? [[String: Any]] {
                selectedSlots = rawSelected.compactMap { dict in
                    guard
                        let email = dict["email"] as? String,
                        let subject = dict["subject"] as? String,
                        let time = dict["time"] as? String
                    else { return nil }

                    return SelectedSlot(subject: subject, email: email, time: time)
                }
            }

            let model = TutorModel(
                uid: uid,
                name: name,
                email: email,
                pricePerHour: pricePerHour,
                subjects: subjects,
                about: data["about"] as? String,
                availableSlots: availableSlots,
                selectedSlots: selectedSlots
            )

            completion(.success(model))
        }
    }
}

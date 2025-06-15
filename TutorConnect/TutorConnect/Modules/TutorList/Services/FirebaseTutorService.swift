//
//  FirebaseTutorService.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 14.06.2025.
//

import Foundation
import FirebaseFirestore

protocol FirebaseTutorServiceProtocol {
    func fetchTutors(completion: @escaping (Result<[TutorModel], Error>) -> Void)
}

final class FirebaseTutorService: FirebaseTutorServiceProtocol {
    private let db = Firestore.firestore()

    func fetchTutors(completion: @escaping (Result<[TutorModel], Error>) -> Void) {
        db.collection("users")
            .whereField("isTutor", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let tutors: [TutorModel] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()

                    guard
                        let uid = data["uid"] as? String,
                        let name = data["name"] as? String,
                        let email = data["email"] as? String,
                        let pricePerHour = data["pricePerHour"] as? Int,
                        let subjects = data["subjects"] as? [String]
                    else {
                        return nil
                    }

                    // Парсинг availableSlots: [String: [Any]] -> [String: [String]]
                    var parsedSlots: [String: [Timestamp]]? = nil
                    if let rawSlots = data["availableSlots"] as? [String: [Any]] {
                        parsedSlots = rawSlots.mapValues { array in
                            array.compactMap { $0 as? Timestamp }
                        }
                    }

                    return TutorModel(
                        uid: uid,
                        name: name,
                        email: email,
                        pricePerHour: pricePerHour,
                        subjects: subjects,
                        about: data["about"] as? String,
                        availableSlots: parsedSlots
                    )
                } ?? []

                completion(.success(tutors))
            }
    }
}

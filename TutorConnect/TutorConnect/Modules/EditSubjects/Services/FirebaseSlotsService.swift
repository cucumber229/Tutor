//
//  FirebaseSlotsService.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 14.06.2025.
//

import Foundation
import Firebase
import FirebaseAuth


protocol FirebaseSlotsServiceProtocol {
    func fetchCurrentTutorSlots(completion: @escaping (Result<[SubjectSlotGroup], Error>) -> Void)
    func deleteSubject(name: String, completion: @escaping (Result<Void, Error>) -> Void)
    func addSubject(name: String, completion: @escaping (Result<Void, Error>) -> Void)
    func addSlot(for subject: String, date: Date, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteSlot(for subject: String, date: Date, completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - Implementation

final class FirebaseSlotsService: FirebaseSlotsServiceProtocol {
    private let db = Firestore.firestore()

    func fetchCurrentTutorSlots(completion: @escaping (Result<[SubjectSlotGroup], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "NoAuth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"]
            )))
            return
        }

        let docRef = db.collection("users").document(uid)

        docRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let isTutor = data["isTutor"] as? Bool, isTutor == true else {
                completion(.failure(NSError(
                    domain: "ParseError",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Данные не найдены или пользователь не является преподавателем"]
                )))
                return
            }

            var groups: [SubjectSlotGroup] = []

            if let rawSlots = data["availableSlots"] as? [String: [Any]] {
                for (subject, values) in rawSlots {
                    let timestamps = values.compactMap { $0 as? Timestamp }
                    groups.append(SubjectSlotGroup(name: subject, slots: timestamps))
                }
            }

            completion(.success(groups.sorted { $0.name < $1.name }))
        }
    }
    
    func deleteSubject(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"])))
            return
        }

        let docRef = db.collection("users").document(uid)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(docRef)
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }

            var subjects = snapshot.data()?["subjects"] as? [String] ?? []
            var slots = snapshot.data()?["availableSlots"] as? [String: [Timestamp]] ?? [:]

            subjects.removeAll { $0 == name }
            slots.removeValue(forKey: name)

            transaction.updateData(["subjects": subjects, "availableSlots": slots], forDocument: docRef)

            return nil
        }) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func addSubject(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "NoAuth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"]
            )))
            return
        }

        let docRef = db.collection("users").document(uid)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(docRef)
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }

            // Существующие предметы
            var currentSubjects = snapshot.data()?["subjects"] as? [String] ?? []

            if !currentSubjects.contains(name) {
                currentSubjects.append(name)
                transaction.updateData(["subjects": currentSubjects], forDocument: docRef)
            }

            // Существующие слоты
            var currentSlots = snapshot.data()?["availableSlots"] as? [String: [Timestamp]] ?? [:]

            if currentSlots[name] == nil {
                currentSlots[name] = []
                transaction.updateData(["availableSlots": currentSlots], forDocument: docRef)
            }

            return nil
        }) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

extension FirebaseSlotsService {
    func addSlot(for subject: String, date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"])))
            return
        }

        let docRef = db.collection("users").document(uid)
        let timestamp = Timestamp(date: date)

        docRef.updateData([
            "availableSlots.\(subject)": FieldValue.arrayUnion([timestamp])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteSlot(for subject: String, date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"])))
            return
        }

        let docRef = db.collection("users").document(uid)
        let timestamp = Timestamp(date: date)

        docRef.updateData([
            "availableSlots.\(subject)": FieldValue.arrayRemove([timestamp])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

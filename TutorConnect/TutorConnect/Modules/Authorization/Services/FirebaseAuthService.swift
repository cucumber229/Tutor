//
//  FirebaseAuthService.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 13.06.2025.
//

import Foundation
import Firebase
import FirebaseAuth

protocol FirebaseAuthServiceProtocol: AnyObject {
    func signUp(email: String, password: String, completion: @escaping (AuthResult) -> Void)
    func signIn(email: String, password: String, completion: @escaping (AuthResult) -> Void)
    func signOut()
}

final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    
    func signUp(email: String, password: String, completion: @escaping (AuthResult) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить результат регистрации."])))
                return
            }

            let uid = result.user.uid
            UserDefaults.standard.set(uid, forKey: "uid")

            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "email": email,
                "password": password,
                "name": "*Пожалуйста, представьтесь*",
                "uid": uid
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success)
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (AuthResult) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(
                    domain: "SignInError",
                    code: 0, userInfo: [NSLocalizedDescriptionKey: "UID не найден."]
                )))
                return
            }

            UserDefaults.standard.set(uid, forKey: "uid")
            completion(.success)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "uid")
        } catch {
            print(error.localizedDescription)
        }
    }
}

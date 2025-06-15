//
//  TutorModel.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 14.06.2025.
//

import Foundation
import FirebaseFirestore

struct TutorModel: Codable {
    let uid: String
    let name: String
    let email: String
    let pricePerHour: Int
    let subjects: [String]
    let about: String?
    var availableSlots: [String: [Timestamp]]?
    var selectedSlots: [SelectedSlot]?
}

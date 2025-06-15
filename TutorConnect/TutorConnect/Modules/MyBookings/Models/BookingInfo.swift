//
//  BookingInfo.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 15.06.2025.
//

import Foundation
import FirebaseCore

struct BookingInfo {
    let subject: String
    let time: Timestamp
    let email: String?
    let tutorId: String?
    let tutorName: String?
}

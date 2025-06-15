//
//  FullBookingData.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 15.06.2025.
//

import Foundation

struct FullBookingData {
    let isTutor: Bool
    let tutorBookings: [BookingInfo]
    let studentBookings: [BookingInfo]
}

//
//  FullBookingData.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 15.06.2025.
//

import Foundation

struct FullBookingData {
    let isTutor: Bool
    let tutorBookings: [BookingInfo]
    let studentBookings: [BookingInfo]
}

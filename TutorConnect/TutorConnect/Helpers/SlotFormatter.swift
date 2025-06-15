//
//  SlotFormatter.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 14.06.2025.
//

import Foundation

enum SlotFormatter {
    static func prettyFormat(from date: Date) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "d MMMM: HH:mm"
        return outputFormatter.string(from: date)
    }
}

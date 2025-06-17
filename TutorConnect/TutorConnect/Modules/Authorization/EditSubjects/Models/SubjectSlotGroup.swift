//
//  SubjectSlotGroup.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 15.06.2025.
//

import Foundation
import FirebaseCore

struct SubjectSlotGroup {
    let name: String
    var slots: [Timestamp]

    init(name: String, slots: [Timestamp] = []) {
        self.name = name
        self.slots = slots
    }
}

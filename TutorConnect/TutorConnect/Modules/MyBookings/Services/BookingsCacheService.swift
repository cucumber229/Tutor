//
//  BookingsCacheService.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 15.06.2025.
//

import Foundation
import CoreData
import FirebaseCore

final class BookingsCacheService {
    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "TutorConnect")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
    }

    private var context: NSManagedObjectContext {
        container.viewContext
    }

    func save(student: [BookingInfo], tutor: [BookingInfo]) {
        clearAll()

        student.forEach { booking in
            let entity = CachedStudentBooking(context: context)
            entity.subject = booking.subject
            entity.tutorId = booking.tutorId ?? ""
            entity.tutorName = booking.tutorName ?? ""
            entity.time = booking.time.dateValue()
        }

        tutor.forEach { booking in
            let entity = CachedTutorBooking(context: context)
            entity.subject = booking.subject
            entity.email = booking.email ?? ""
            entity.time = booking.time.dateValue()
        }

        try? context.save()
    }

    func load() -> FullBookingData? {
        let studentRequest: NSFetchRequest<CachedStudentBooking> = CachedStudentBooking.fetchRequest()
        let tutorRequest: NSFetchRequest<CachedTutorBooking> = CachedTutorBooking.fetchRequest()

        guard let studentRaw = try? context.fetch(studentRequest),
              let tutorRaw = try? context.fetch(tutorRequest) else {
            return nil
        }

        let studentBookings: [BookingInfo] = studentRaw.compactMap { booking in
            guard
                let subject = booking.subject,
                let time = booking.time,
                let tutorId = booking.tutorId,
                let tutorName = booking.tutorName
            else {
                return nil
            }

            return BookingInfo(
                subject: subject,
                time: Timestamp(date: time),
                email: nil,
                tutorId: tutorId,
                tutorName: tutorName
            )
        }

        let tutorBookings: [BookingInfo] = tutorRaw.compactMap { booking in
            guard
                let subject = booking.subject,
                let email = booking.email,
                let time = booking.time
            else {
                return nil
            }

            return BookingInfo(
                subject: subject,
                time: Timestamp(date: time),
                email: email,
                tutorId: nil,
                tutorName: nil
            )
        }

        return FullBookingData(isTutor: !tutorBookings.isEmpty, tutorBookings: tutorBookings, studentBookings: studentBookings)
    }

    func clearAll() {
        [CachedTutorBooking.self, CachedStudentBooking.self].forEach { entityType in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entityType))
            let delete = NSBatchDeleteRequest(fetchRequest: request)
            _ = try? context.execute(delete)
        }
    }
}

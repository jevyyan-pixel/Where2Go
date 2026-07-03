import Foundation
import SwiftData

@Model
final class TripItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var startAt: Date
    var endAt: Date?
    var categoryRawValue: String
    var locationName: String
    var latitude: Double?
    var longitude: Double?
    var isReservation: Bool
    var notes: String
    var reminderRawValue: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        startAt: Date,
        endAt: Date? = nil,
        category: TripCategory,
        locationName: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        isReservation: Bool = false,
        notes: String = "",
        reminder: ReminderOption = .none,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.startAt = startAt
        self.endAt = endAt
        self.categoryRawValue = category.rawValue
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.isReservation = isReservation
        self.notes = notes
        self.reminderRawValue = reminder.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var category: TripCategory {
        get { TripCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }

    var reminder: ReminderOption {
        get { ReminderOption(rawValue: reminderRawValue) ?? .none }
        set { reminderRawValue = newValue.rawValue }
    }
}

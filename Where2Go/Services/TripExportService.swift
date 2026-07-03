import Foundation

struct TripExportRecord: Codable {
    let id: UUID
    let title: String
    let startAt: Date
    let endAt: Date?
    let category: String
    let locationName: String
    let latitude: Double?
    let longitude: Double?
    let isReservation: Bool
    let notes: String
    let reminder: String
    let createdAt: Date
    let updatedAt: Date

    init(trip: TripItem) {
        self.id = trip.id
        self.title = trip.title
        self.startAt = trip.startAt
        self.endAt = trip.endAt
        self.category = trip.category.rawValue
        self.locationName = trip.locationName
        self.latitude = trip.latitude
        self.longitude = trip.longitude
        self.isReservation = trip.isReservation
        self.notes = trip.notes
        self.reminder = trip.reminder.rawValue
        self.createdAt = trip.createdAt
        self.updatedAt = trip.updatedAt
    }
}

enum TripExportService {
    static func exportJSON(from trips: [TripItem]) throws -> URL {
        let records = trips
            .sorted { $0.startAt < $1.startAt }
            .map(TripExportRecord.init)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(records)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Where2Go-行程备份")
            .appendingPathExtension("json")
        try data.write(to: url, options: [.atomic])
        return url
    }
}

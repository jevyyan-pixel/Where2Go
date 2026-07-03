import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let dailySummaryPrefix = "daily-trip-summary"

    private init() {}

    func requestAuthorizationIfNeeded() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        @unknown default:
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    func pendingDailySummaryCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.filter { $0.identifier.hasPrefix(dailySummaryPrefix) }.count
    }

    func scheduleReminder(for trip: TripItem) async throws {
        guard let triggerDate = trip.reminder.triggerDate(for: trip.startAt), triggerDate > Date() else {
            return
        }

        let allowed = try await requestAuthorizationIfNeeded()
        guard allowed else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = trip.isReservation ? "预约行程提醒" : "行程提醒"
        content.body = trip.locationName.isEmpty ? trip.title : "\(trip.title) · \(trip.locationName)"
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: trip.id.uuidString, content: content, trigger: trigger)

        try await UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for tripID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [tripID.uuidString])
    }

    func scheduleDailySummaries(for trips: [TripItem], hour: Int, minute: Int, days: Int = 7) async throws {
        let allowed = try await requestAuthorizationIfNeeded()
        guard allowed else {
            return
        }

        await cancelDailySummaries()

        let calendar = Calendar.current
        let dates = TripQueryService.scheduleDates(days: days, calendar: calendar)
        for date in dates {
            guard let triggerDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date), triggerDate > Date() else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = "今天去哪玩"
            content.body = TripQueryService.notificationSummary(for: date, trips: trips, calendar: calendar)
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: dailySummaryIdentifier(for: date, calendar: calendar), content: content, trigger: trigger)

            try await UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelDailySummaries() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        let identifiers = requests
            .map(\.identifier)
            .filter { $0.hasPrefix(dailySummaryPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func dailySummaryIdentifier(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return "\(dailySummaryPrefix)-\(year)-\(month)-\(day)"
    }
}

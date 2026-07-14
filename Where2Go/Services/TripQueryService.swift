import Foundation

enum TripQueryService {
    static func startOfDay(for date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func trips(on date: Date, from trips: [TripItem], calendar: Calendar = .current) -> [TripItem] {
        trips
            .filter { calendar.isDate($0.startAt, inSameDayAs: date) }
            .sorted { $0.startAt < $1.startAt }
    }

    static func upcomingReferenceDate(from trips: [TripItem], now: Date = Date(), calendar: Calendar = .current) -> Date? {
        let todayRemaining = trips
            .filter { $0.startAt >= now && calendar.isDate($0.startAt, inSameDayAs: now) }
            .sorted { $0.startAt < $1.startAt }

        if let firstToday = todayRemaining.first {
            return calendar.startOfDay(for: firstToday.startAt)
        }

        return trips
            .filter { $0.startAt >= now }
            .sorted { $0.startAt < $1.startAt }
            .first
            .map { calendar.startOfDay(for: $0.startAt) }
    }

    static func groupedByDay(_ trips: [TripItem], calendar: Calendar = .current) -> [(date: Date, trips: [TripItem])] {
        let groups = Dictionary(grouping: trips) { trip in
            calendar.startOfDay(for: trip.startAt)
        }

        return groups
            .map { (date: $0.key, trips: $0.value.sorted { $0.startAt < $1.startAt }) }
            .sorted { $0.date < $1.date }
    }

    static func upcomingTrips(_ trips: [TripItem], now: Date = Date()) -> [TripItem] {
        trips
            .filter { $0.startAt >= now }
            .sorted { $0.startAt < $1.startAt }
    }

    static func pastTrips(_ trips: [TripItem], now: Date = Date()) -> [TripItem] {
        trips
            .filter { $0.startAt < now }
            .sorted { $0.startAt > $1.startAt }
    }

    static func groupedPastByDay(_ trips: [TripItem], calendar: Calendar = .current) -> [(date: Date, trips: [TripItem])] {
        let groups = Dictionary(grouping: trips) { trip in
            calendar.startOfDay(for: trip.startAt)
        }

        return groups
            .map { (date: $0.key, trips: $0.value.sorted { $0.startAt > $1.startAt }) }
            .sorted { $0.date > $1.date }
    }

    static func relativeDayText(for date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        if calendar.isDate(date, inSameDayAs: now) {
            return "今天"
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return "明天"
        }

        return date.formatted(.dateTime.month().day().weekday(.wide))
    }

    static func summary(for date: Date, trips: [TripItem], now: Date = Date(), calendar: Calendar = .current) -> String {
        let dayTrips = self.trips(on: date, from: trips, calendar: calendar)
        guard !dayTrips.isEmpty else {
            return "最近还没有计划，要不要安排一个小行程？"
        }

        let prefix = relativeDayText(for: date, now: now, calendar: calendar)
        let descriptions = dayTrips.prefix(4).map { trip in
            let time = trip.startAt.formatted(.dateTime.hour().minute())
            if trip.locationName.isEmpty {
                return "\(time) \(trip.title)"
            }
            return "\(time) \(trip.locationName)\(trip.title)"
        }

        let extra = dayTrips.count > descriptions.count ? "，还有 \(dayTrips.count - descriptions.count) 个安排" : ""
        return "\(prefix)有 \(dayTrips.count) 个安排：\(descriptions.joined(separator: "，"))\(extra)。建议提前确认交通时间，并整理好所需资料。"
    }

    static func notificationSummary(for date: Date, trips: [TripItem], calendar: Calendar = .current) -> String {
        let dayTrips = self.trips(on: date, from: trips, calendar: calendar)
        guard !dayTrips.isEmpty else {
            return "今天还没有安排。想出门的话，可以先加一个小计划。"
        }

        let descriptions = dayTrips.prefix(3).map { trip in
            let time = trip.startAt.formatted(.dateTime.hour().minute())
            if trip.locationName.isEmpty {
                return "\(time) \(trip.title)"
            }
            return "\(time) \(trip.title) @ \(trip.locationName)"
        }
        let extra = dayTrips.count > descriptions.count ? "，另有 \(dayTrips.count - descriptions.count) 项" : ""
        return "今天有 \(dayTrips.count) 个安排：\(descriptions.joined(separator: "，"))\(extra)。"
    }

    static func scheduleDates(from startDate: Date = Date(), days: Int, calendar: Calendar = .current) -> [Date] {
        guard days > 0 else { return [] }
        return (0..<days).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: startDate))
        }
    }
}

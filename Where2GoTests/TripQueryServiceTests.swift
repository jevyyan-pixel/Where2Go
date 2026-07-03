import XCTest
@testable import Where2Go

final class TripQueryServiceTests: XCTestCase {
    func testReminderOffsetComputesFifteenMinutesBeforeStart() throws {
        let calendar = Calendar(identifier: .gregorian)
        let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 13, minute: 0)))
        let trigger = try XCTUnwrap(ReminderOption.minutes15Before.triggerDate(for: start, calendar: calendar))

        XCTAssertEqual(calendar.component(.hour, from: trigger), 12)
        XCTAssertEqual(calendar.component(.minute, from: trigger), 45)
    }

    func testUpcomingReferenceDatePrefersTodayRemainingTrips() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 12, minute: 0)))
        let morning = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 9, minute: 0)))
        let afternoon = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 15, minute: 0)))
        let tomorrow = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 5, hour: 10, minute: 0)))
        let trips = [
            TripItem(title: "已结束早餐", startAt: morning, category: .food),
            TripItem(title: "下午咖啡", startAt: afternoon, category: .food),
            TripItem(title: "明天展览", startAt: tomorrow, category: .play),
        ]

        let referenceDate = try XCTUnwrap(TripQueryService.upcomingReferenceDate(from: trips, now: now, calendar: calendar))

        XCTAssertTrue(calendar.isDate(referenceDate, inSameDayAs: now))
    }

    func testGroupedByDaySortsDaysDescendingAndTripsAscending() throws {
        let calendar = Calendar(identifier: .gregorian)
        let firstDayMorning = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 9, minute: 0)))
        let firstDayEvening = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 19, minute: 0)))
        let secondDayNoon = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 5, hour: 12, minute: 0)))
        let trips = [
            TripItem(title: "晚餐", startAt: firstDayEvening, category: .food),
            TripItem(title: "午餐", startAt: secondDayNoon, category: .food),
            TripItem(title: "早餐", startAt: firstDayMorning, category: .food),
        ]

        let grouped = TripQueryService.groupedByDay(trips, calendar: calendar)

        XCTAssertEqual(grouped.count, 2)
        XCTAssertTrue(calendar.isDate(grouped[0].date, inSameDayAs: secondDayNoon))
        XCTAssertEqual(grouped[1].trips.map(\.title), ["早餐", "晚餐"])
    }

    func testNotificationSummaryIncludesTodayTrips() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 8, minute: 0)))
        let coffee = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 15, minute: 0)))
        let trips = [
            TripItem(title: "喝咖啡", startAt: coffee, category: .food, locationName: "正佳广场"),
        ]

        let summary = TripQueryService.notificationSummary(for: date, trips: trips, calendar: calendar)

        XCTAssertTrue(summary.contains("今天有 1 个安排"))
        XCTAssertTrue(summary.contains("15:00"))
        XCTAssertTrue(summary.contains("喝咖啡"))
        XCTAssertTrue(summary.contains("正佳广场"))
    }

    func testNotificationSummaryHandlesEmptyDay() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4)))

        let summary = TripQueryService.notificationSummary(for: date, trips: [], calendar: calendar)

        XCTAssertTrue(summary.contains("今天还没有安排"))
    }

    func testScheduleDatesCreatesConsecutiveStartOfDayValues() throws {
        let calendar = Calendar(identifier: .gregorian)
        let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 7, day: 4, hour: 18)))

        let dates = TripQueryService.scheduleDates(from: start, days: 3, calendar: calendar)

        XCTAssertEqual(dates.count, 3)
        XCTAssertEqual(calendar.component(.day, from: dates[0]), 4)
        XCTAssertEqual(calendar.component(.day, from: dates[1]), 5)
        XCTAssertEqual(calendar.component(.day, from: dates[2]), 6)
        XCTAssertEqual(calendar.component(.hour, from: dates[0]), 0)
    }
}

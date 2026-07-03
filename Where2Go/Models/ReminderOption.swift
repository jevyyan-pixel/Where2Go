import Foundation

enum ReminderOption: String, CaseIterable, Identifiable, Codable {
    case none
    case atTime
    case minutes15Before
    case hour1Before
    case morningOfDay
    case dayBefore

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: "不提醒"
        case .atTime: "开始时"
        case .minutes15Before: "提前 15 分钟"
        case .hour1Before: "提前 1 小时"
        case .morningOfDay: "当天早上"
        case .dayBefore: "提前一天"
        }
    }

    func triggerDate(for startAt: Date, calendar: Calendar = .current) -> Date? {
        switch self {
        case .none:
            return nil
        case .atTime:
            return startAt
        case .minutes15Before:
            return calendar.date(byAdding: .minute, value: -15, to: startAt)
        case .hour1Before:
            return calendar.date(byAdding: .hour, value: -1, to: startAt)
        case .morningOfDay:
            return calendar.date(bySettingHour: 8, minute: 30, second: 0, of: startAt)
        case .dayBefore:
            guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: startAt) else {
                return nil
            }
            return calendar.date(bySettingHour: 20, minute: 0, second: 0, of: dayBefore)
        }
    }
}

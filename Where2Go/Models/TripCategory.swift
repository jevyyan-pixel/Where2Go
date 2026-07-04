import SwiftUI

enum TripCategory: String, CaseIterable, Identifiable, Codable {
    case food
    case play
    case study
    case work
    case transport
    case sport
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food: "吃喝"
        case .play: "玩乐"
        case .study: "学习"
        case .work: "工作"
        case .transport: "交通"
        case .sport: "运动"
        case .other: "其他"
        }
    }

    var symbolName: String {
        switch self {
        case .food: "fork.knife"
        case .play: "sparkles"
        case .study: "book.closed"
        case .work: "briefcase"
        case .transport: "tram.fill"
        case .sport: "figure.run"
        case .other: "circle.grid.2x2"
        }
    }

    var tint: Color {
        switch self {
        case .food: Color(red: 0.73, green: 0.44, blue: 0.27)
        case .play: Color(red: 0.55, green: 0.44, blue: 0.68)
        case .study: Color(red: 0.37, green: 0.45, blue: 0.52)
        case .work: Color(red: 0.29, green: 0.36, blue: 0.35)
        case .transport: Color(red: 0.31, green: 0.49, blue: 0.55)
        case .sport: Color(red: 0.44, green: 0.56, blue: 0.45)
        case .other: Color(red: 0.54, green: 0.53, blue: 0.49)
        }
    }
}

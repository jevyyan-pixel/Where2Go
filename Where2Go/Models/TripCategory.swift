import SwiftUI

enum TripCategory: String, CaseIterable, Identifiable, Codable {
    case food
    case play
    case study
    case work
    case transport
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food: "吃喝"
        case .play: "玩乐"
        case .study: "学习"
        case .work: "工作"
        case .transport: "交通"
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
        case .other: "circle.grid.2x2"
        }
    }

    var tint: Color {
        switch self {
        case .food: .orange
        case .play: .cyan
        case .study: .indigo
        case .work: .blue
        case .transport: .green
        case .other: .gray
        }
    }
}

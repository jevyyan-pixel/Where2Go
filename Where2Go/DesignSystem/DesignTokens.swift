import SwiftUI

enum DesignTokens {
    static let accent = Color(red: 0.10, green: 0.42, blue: 0.86)
    static let subduedText = Color.secondary
    static let cardRadius: CGFloat = 8
    static let pageSpacing: CGFloat = 18
    static let rowSpacing: CGFloat = 12

    #if os(iOS)
    static let softBackground = Color(uiColor: .secondarySystemBackground)
    static let cardBackground = Color(uiColor: .systemBackground)
    #elseif os(macOS)
    static let softBackground = Color(nsColor: .underPageBackgroundColor)
    static let cardBackground = Color(nsColor: .windowBackgroundColor)
    #else
    static let softBackground = Color.gray.opacity(0.12)
    static let cardBackground = Color.white
    #endif
}

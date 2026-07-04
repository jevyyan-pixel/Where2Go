import SwiftUI

enum DesignTokens {
    static let accent = Color(red: 0.09, green: 0.23, blue: 0.21)
    static let gold = Color(red: 0.79, green: 0.64, blue: 0.36)
    static let subduedText = Color(red: 0.49, green: 0.46, blue: 0.41)
    static let cardRadius: CGFloat = 14
    static let pageSpacing: CGFloat = 18
    static let rowSpacing: CGFloat = 12
    static let controlRadius: CGFloat = 11

    #if os(iOS)
    static let softBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.08, blue: 0.07, alpha: 1.0)
            : UIColor(red: 0.97, green: 0.95, blue: 0.92, alpha: 1.0)
    })
    static let cardBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.13, blue: 0.12, alpha: 1.0)
            : UIColor(red: 1.00, green: 0.99, blue: 0.97, alpha: 1.0)
    })
    static let elevatedBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.17, blue: 0.15, alpha: 1.0)
            : UIColor(red: 0.98, green: 0.96, blue: 0.91, alpha: 1.0)
    })
    static let cardBorder = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.28, green: 0.27, blue: 0.22, alpha: 1.0)
            : UIColor(red: 0.90, green: 0.87, blue: 0.82, alpha: 1.0)
    })
    #elseif os(macOS)
    static let softBackground = Color(nsColor: .underPageBackgroundColor)
    static let cardBackground = Color(nsColor: .windowBackgroundColor)
    static let elevatedBackground = Color(nsColor: .controlBackgroundColor)
    static let cardBorder = Color.gray.opacity(0.2)
    #else
    static let softBackground = Color.gray.opacity(0.12)
    static let cardBackground = Color.white
    static let elevatedBackground = Color.white.opacity(0.8)
    static let cardBorder = Color.gray.opacity(0.2)
    #endif

    static let subtleShadow = Color.black.opacity(0.08)
    static let capsuleBackground = gold.opacity(0.16)
    static let iconBackgroundOpacity = 0.14
}

extension View {
    func conciergeCardStyle(cornerRadius: CGFloat = DesignTokens.cardRadius) -> some View {
        self
            .background(DesignTokens.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DesignTokens.cardBorder, lineWidth: 1)
            }
            .shadow(color: DesignTokens.subtleShadow, radius: 16, x: 0, y: 8)
    }
}

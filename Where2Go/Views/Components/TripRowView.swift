import SwiftUI

struct TripRowView: View {
    let trip: TripItem
    var isPast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                Image(systemName: trip.category.symbolName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconForeground)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(trip.startAt, format: .dateTime.hour().minute())
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(timeColor)

                    Text(trip.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(titleColor)
                        .lineLimit(2)

                    Spacer(minLength: 0)
                }

                HStack(spacing: 7) {
                    Text(trip.category.title)
                        .foregroundStyle(iconForeground)
                    if !trip.locationName.isEmpty {
                        Label(trip.locationName, systemImage: "mappin.and.ellipse")
                            .labelStyle(.titleAndIcon)
                    }
                    Spacer(minLength: 0)
                    if trip.isReservation {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                            Text("已预约")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isPast ? DesignTokens.subduedText : DesignTokens.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(reservationBackground, in: Capsule())
                    }
                }
                .font(.footnote)
                .foregroundStyle(DesignTokens.subduedText)
                .lineLimit(1)
            }
        }
        .padding(15)
        .conciergeCardStyle()
        .saturation(isPast ? 0.2 : 1)
        .opacity(isPast ? 0.68 : 1)
        .accessibilityElement(children: .combine)
    }

    private var iconForeground: Color {
        isPast ? DesignTokens.subduedText : trip.category.tint
    }

    private var iconBackground: Color {
        iconForeground.opacity(isPast ? 0.10 : DesignTokens.iconBackgroundOpacity)
    }

    private var timeColor: Color {
        isPast ? DesignTokens.subduedText : DesignTokens.accent
    }

    private var titleColor: Color {
        isPast ? DesignTokens.subduedText : .primary
    }

    private var reservationBackground: Color {
        isPast ? DesignTokens.subduedText.opacity(0.12) : DesignTokens.capsuleBackground
    }
}

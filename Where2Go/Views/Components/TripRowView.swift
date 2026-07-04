import SwiftUI

struct TripRowView: View {
    let trip: TripItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(trip.category.tint.opacity(DesignTokens.iconBackgroundOpacity))
                Image(systemName: trip.category.symbolName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(trip.category.tint)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(trip.startAt, format: .dateTime.hour().minute())
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(DesignTokens.accent)

                    Text(trip.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer(minLength: 0)
                }

                HStack(spacing: 7) {
                    Text(trip.category.title)
                        .foregroundStyle(trip.category.tint)
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
                        .foregroundStyle(DesignTokens.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignTokens.capsuleBackground, in: Capsule())
                    }
                }
                .font(.footnote)
                .foregroundStyle(DesignTokens.subduedText)
                .lineLimit(1)
            }
        }
        .padding(15)
        .conciergeCardStyle()
        .accessibilityElement(children: .combine)
    }
}

import SwiftUI

struct TripRowView: View {
    let trip: TripItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(trip.category.tint.opacity(0.16))
                Image(systemName: trip.category.symbolName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(trip.category.tint)
            }
            .frame(width: 38, height: 38)

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

                HStack(spacing: 8) {
                    Text(trip.category.title)
                    if !trip.locationName.isEmpty {
                        Label(trip.locationName, systemImage: "mappin.and.ellipse")
                            .labelStyle(.titleAndIcon)
                    }
                    if trip.isReservation {
                        Label("已预约", systemImage: "checkmark.seal.fill")
                            .labelStyle(.titleAndIcon)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
        }
        .padding(14)
        .background(DesignTokens.cardBackground, in: RoundedRectangle(cornerRadius: DesignTokens.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

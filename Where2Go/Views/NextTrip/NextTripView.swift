import SwiftData
import SwiftUI

struct NextTripView: View {
    @Binding var isPresentingTripForm: Bool
    @Binding var selectedDate: Date
    @Query(sort: \TripItem.startAt) private var trips: [TripItem]

    private var referenceDate: Date? {
        TripQueryService.upcomingReferenceDate(from: trips)
    }

    private var visibleTrips: [TripItem] {
        guard let referenceDate else { return [] }
        return TripQueryService.trips(on: referenceDate, from: trips)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.pageSpacing) {
                    if let referenceDate {
                        summaryCard(for: referenceDate)

                        VStack(alignment: .leading, spacing: DesignTokens.rowSpacing) {
                            Text(TripQueryService.relativeDayText(for: referenceDate))
                                .font(.headline)
                                .foregroundStyle(.primary)

                            ForEach(visibleTrips) { trip in
                                NavigationLink {
                                    TripDetailView(trip: trip)
                                } label: {
                                    TripRowView(trip: trip)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                        EmptyStateView(
                            title: "最近还没有计划",
                            message: "想去哪里、什么时候出发，先记下来。Where2Go 会帮你整理成清楚的行程 Briefing。",
                            systemImage: "calendar.badge.plus",
                            actionTitle: "新增行程"
                        ) {
                            selectedDate = Date()
                            isPresentingTripForm = true
                        }
                    }
                }
                .padding()
            }
            .background(DesignTokens.softBackground)
            .navigationTitle("下一程")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedDate = referenceDate ?? Date()
                        isPresentingTripForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新增行程")
                }
            }
        }
    }

    private func summaryCard(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("行程 Briefing", systemImage: "sparkles")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignTokens.gold)

            Text(TripQueryService.relativeDayText(for: date))
                .font(.callout.weight(.semibold))
                .foregroundStyle(DesignTokens.accent)

            Text(TripQueryService.summary(for: date, trips: trips))
                .font(.title3.weight(.semibold))
                .lineSpacing(4)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .conciergeCardStyle()
    }
}

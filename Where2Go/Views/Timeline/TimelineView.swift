import SwiftData
import SwiftUI

struct TripTimelineView: View {
    @Binding var isPresentingTripForm: Bool
    @Binding var selectedDate: Date
    @Query(sort: \TripItem.startAt, order: .reverse) private var trips: [TripItem]

    private var groupedTrips: [(date: Date, trips: [TripItem])] {
        TripQueryService.groupedByDay(trips)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignTokens.pageSpacing, pinnedViews: [.sectionHeaders]) {
                    if groupedTrips.isEmpty {
                        EmptyStateView(
                            title: "还没有任何行程",
                            message: "新增一个安排后，这里会按日期整理你的全部行程。",
                            systemImage: "list.bullet.rectangle",
                            actionTitle: "新增行程"
                        ) {
                            selectedDate = Date()
                            isPresentingTripForm = true
                        }
                    } else {
                        ForEach(groupedTrips, id: \.date) { group in
                            Section {
                                VStack(spacing: DesignTokens.rowSpacing) {
                                    ForEach(group.trips) { trip in
                                        NavigationLink {
                                            TripDetailView(trip: trip)
                                        } label: {
                                            TripRowView(trip: trip)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(DesignTokens.gold)
                                        .frame(width: 6, height: 6)
                                    Text(TripQueryService.relativeDayText(for: group.date))
                                        .font(.headline)
                                        .foregroundStyle(DesignTokens.accent)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .background(DesignTokens.softBackground)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(DesignTokens.softBackground)
            .navigationTitle("时间线")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedDate = Date()
                        isPresentingTripForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新增行程")
                }
            }
        }
    }
}

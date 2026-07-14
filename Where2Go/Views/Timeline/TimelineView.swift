import SwiftData
import SwiftUI

struct TripTimelineView: View {
    @Binding var isPresentingTripForm: Bool
    @Binding var selectedDate: Date
    @Query(sort: \TripItem.startAt, order: .forward) private var trips: [TripItem]
    @State private var showsPastTrips = false
    private let historyCollapseOffset: CGFloat = 0
    private let historyScrollRunwayHeight: CGFloat = 260

    private var upcomingGroups: [(date: Date, trips: [TripItem])] {
        TripQueryService.groupedByDay(TripQueryService.upcomingTrips(trips))
    }

    private var pastGroups: [(date: Date, trips: [TripItem])] {
        TripQueryService.groupedPastByDay(TripQueryService.pastTrips(trips))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignTokens.pageSpacing, pinnedViews: [.sectionHeaders]) {
                    if trips.isEmpty {
                        EmptyStateView(
                            title: "还没有任何行程",
                            message: "新增一个安排后，这里会按日期整理你的全部行程。",
                            systemImage: "list.bullet.rectangle",
                            actionTitle: "新增行程"
                        ) {
                            selectedDate = Date()
                            isPresentingTripForm = true
                        }
                    } else if upcomingGroups.isEmpty && !showsPastTrips {
                        EmptyStateView(
                            title: "暂无待进行行程",
                            message: "最近的安排都已经完成，可以继续添加下一程。",
                            systemImage: "checkmark.circle",
                            actionTitle: "新增行程"
                        ) {
                            selectedDate = Date()
                            isPresentingTripForm = true
                        }
                    } else {
                        if showsPastTrips {
                            ForEach(pastGroups, id: \.date) { group in
                                tripSection(for: group, isPast: true)
                            }

                            historyBoundary
                        }

                        ForEach(upcomingGroups, id: \.date) { group in
                            tripSection(for: group, isPast: false)
                        }

                        if showsPastTrips {
                            historyScrollRunway
                        }
                    }
                }
                .padding()
            }
            .coordinateSpace(name: "timelineScroll")
            .onPreferenceChange(TimelineHistoryBoundaryPreferenceKey.self) { minY in
                guard showsPastTrips, let minY, minY < historyCollapseOffset else { return }
                withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                    showsPastTrips = false
                }
            }
            .refreshable {
                guard !pastGroups.isEmpty else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    showsPastTrips = true
                }
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

    private func tripSection(for group: (date: Date, trips: [TripItem]), isPast: Bool) -> some View {
        Section {
            VStack(spacing: DesignTokens.rowSpacing) {
                ForEach(group.trips) { trip in
                    NavigationLink {
                        TripDetailView(trip: trip)
                    } label: {
                        TripRowView(trip: trip, isPast: isPast)
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            HStack(spacing: 8) {
                Circle()
                    .fill(isPast ? DesignTokens.subduedText.opacity(0.55) : DesignTokens.gold)
                    .frame(width: 6, height: 6)
                Text(sectionTitle(for: group.date, isPast: isPast))
                    .font(.headline)
                    .foregroundStyle(isPast ? DesignTokens.subduedText : DesignTokens.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .background(DesignTokens.softBackground)
        }
    }

    private func sectionTitle(for date: Date, isPast: Bool) -> String {
        let title = TripQueryService.relativeDayText(for: date)
        return title
    }

    private var historyBoundary: some View {
        Color.clear
            .frame(height: 1)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: TimelineHistoryBoundaryPreferenceKey.self,
                        value: proxy.frame(in: .named("timelineScroll")).minY
                    )
                }
            }
    }

    private var historyScrollRunway: some View {
        Color.clear
            .frame(height: historyScrollRunwayHeight)
            .accessibilityHidden(true)
    }
}

private struct TimelineHistoryBoundaryPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue() ?? value
    }
}

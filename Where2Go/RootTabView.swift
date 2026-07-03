import SwiftData
import SwiftUI

struct RootTabView: View {
    @State private var isPresentingTripForm = false
    @State private var selectedDate = Date()
    @Query(sort: \TripItem.startAt) private var trips: [TripItem]
    @AppStorage("dailySummaryEnabled") private var dailySummaryEnabled = false
    @AppStorage("dailySummaryHour") private var dailySummaryHour = 8
    @AppStorage("dailySummaryMinute") private var dailySummaryMinute = 30
    @AppStorage("appearanceMode") private var appearanceMode = "system"

    private var summaryScheduleKey: String {
        let latestUpdate = trips.map(\.updatedAt).max() ?? .distantPast
        return "\(dailySummaryEnabled)-\(dailySummaryHour)-\(dailySummaryMinute)-\(trips.count)-\(latestUpdate.timeIntervalSince1970)"
    }

    var body: some View {
        TabView {
            NextTripView(isPresentingTripForm: $isPresentingTripForm, selectedDate: $selectedDate)
                .tabItem {
                    Label("下一程", systemImage: "sparkles")
                }

            MonthCalendarView(isPresentingTripForm: $isPresentingTripForm, selectedDate: $selectedDate)
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }

            TripTimelineView(isPresentingTripForm: $isPresentingTripForm, selectedDate: $selectedDate)
                .tabItem {
                    Label("时间线", systemImage: "list.bullet.rectangle")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
        .tint(DesignTokens.accent)
        .sheet(isPresented: $isPresentingTripForm) {
            TripFormView(defaultDate: selectedDate)
                .presentationDetents([.large])
        }
        .task {
            await refreshDailySummaries()
        }
        .onChange(of: summaryScheduleKey) { _, _ in
            Task {
                await refreshDailySummaries()
            }
        }
        .preferredColorScheme(preferredColorScheme)
    }

    private func refreshDailySummaries() async {
        if dailySummaryEnabled {
            try? await NotificationService.shared.scheduleDailySummaries(for: trips, hour: dailySummaryHour, minute: dailySummaryMinute)
        } else {
            await NotificationService.shared.cancelDailySummaries()
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }
}

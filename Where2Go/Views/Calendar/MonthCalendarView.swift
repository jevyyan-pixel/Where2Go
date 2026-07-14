import SwiftData
import SwiftUI

struct MonthCalendarView: View {
    @Binding var isPresentingTripForm: Bool
    @Binding var selectedDate: Date
    @Query(sort: \TripItem.startAt) private var trips: [TripItem]

    @State private var displayedMonth = Date()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.pageSpacing) {
                    monthHeader
                    weekdayHeader
                    calendarGrid
                    selectedDaySection
                }
                .padding()
            }
            .background(DesignTokens.softBackground)
            .navigationTitle("日历")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingTripForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新增行程")
                }
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("上个月")

            Spacer()

            Text(displayedMonth.formatted(.dateTime.year().month(.wide)))
                .font(.title3.weight(.semibold))
                .foregroundStyle(DesignTokens.accent)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("下个月")
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(daysForDisplayedMonth(), id: \.self) { date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear
                        .frame(height: 46)
                }
            }
        }
    }

    private var selectedDaySection: some View {
        let dayTrips = TripQueryService.trips(on: selectedDate, from: trips)

        return VStack(alignment: .leading, spacing: DesignTokens.rowSpacing) {
            Text(selectedDate.formatted(.dateTime.month().day().weekday(.wide)))
                .font(.headline)
                .foregroundStyle(DesignTokens.accent)
                .frame(maxWidth: .infinity, alignment: .leading)

            if dayTrips.isEmpty {
                EmptyStateView(
                    title: "这天还没有安排",
                    message: "可以先加一个吃饭、玩乐或学习计划。",
                    systemImage: "calendar",
                    actionTitle: "新增这天的行程"
                ) {
                    isPresentingTripForm = true
                }
            } else {
                ForEach(dayTrips) { trip in
                    NavigationLink {
                        TripDetailView(trip: trip)
                    } label: {
                        TripRowView(trip: trip, isPast: trip.startAt < Date())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let calendar = Calendar.current
        let dayTrips = TripQueryService.trips(on: date, from: trips)
        let hasTrips = !dayTrips.isEmpty
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let markerColor = dayTrips.first?.category.tint ?? DesignTokens.accent

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isSelected || isToday ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : .primary)

                Circle()
                    .fill(hasTrips ? (isSelected ? DesignTokens.gold : markerColor) : .clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(isSelected ? DesignTokens.accent : DesignTokens.cardBackground, in: RoundedRectangle(cornerRadius: DesignTokens.controlRadius, style: .continuous))
            .overlay {
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: DesignTokens.controlRadius, style: .continuous)
                        .stroke(DesignTokens.gold.opacity(0.75), lineWidth: 1)
                } else if !isSelected {
                    RoundedRectangle(cornerRadius: DesignTokens.controlRadius, style: .continuous)
                        .stroke(DesignTokens.cardBorder, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(.dateTime.month().day().weekday(.wide)))
    }

    private func daysForDisplayedMonth() -> [Date?] {
        let calendar = Calendar.current
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth)
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyDays = firstWeekday - calendar.firstWeekday
        let normalizedLeading = leadingEmptyDays >= 0 ? leadingEmptyDays : leadingEmptyDays + 7
        let dates = monthRange.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }

        return Array(repeating: nil, count: normalizedLeading) + dates
    }

    private func moveMonth(by value: Int) {
        displayedMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
    }
}

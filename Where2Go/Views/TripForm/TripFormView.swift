import SwiftData
import SwiftUI

struct TripFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("defaultReminder") private var defaultReminder = ReminderOption.none.rawValue

    let defaultDate: Date

    @State private var title = ""
    @State private var startAt: Date
    @State private var category: TripCategory = .play
    @State private var locationName = ""
    @State private var isReservation = false
    @State private var reminder: ReminderOption
    @State private var notes = ""
    @State private var saveError: String?
    private let editingTrip: TripItem?

    init(defaultDate: Date) {
        self.defaultDate = defaultDate
        self.editingTrip = nil
        let roundedDefault = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: defaultDate) ?? defaultDate
        _startAt = State(initialValue: roundedDefault)
        _reminder = State(initialValue: .none)
    }

    init(trip: TripItem) {
        self.defaultDate = trip.startAt
        _title = State(initialValue: trip.title)
        _startAt = State(initialValue: trip.startAt)
        _category = State(initialValue: trip.category)
        _locationName = State(initialValue: trip.locationName)
        _isReservation = State(initialValue: trip.isReservation)
        _reminder = State(initialValue: trip.reminder)
        _notes = State(initialValue: trip.notes)
        self.editingTrip = trip
    }

    private var isEditing: Bool {
        editingTrip != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("事项，例如 参观省博物馆", text: $title)
                        .textInputAutocapitalization(.never)

                    DatePicker("时间", selection: $startAt, displayedComponents: [.date, .hourAndMinute])

                    Picker("类型", selection: $category) {
                        ForEach(TripCategory.allCases) { category in
                            Label(category.title, systemImage: category.symbolName)
                                .tag(category)
                        }
                    }
                }

                Section("地点与预约") {
                    TextField("地点，可先填写文字", text: $locationName)
                        .textInputAutocapitalization(.never)

                    Toggle("这是预约项目", isOn: $isReservation)
                }

                Section("提醒") {
                    Picker("提醒时间", selection: $reminder) {
                        ForEach(ReminderOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                }

                Section("备注") {
                    TextField("补充说明", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let saveError {
                    Section {
                        Text(saveError)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑行程" : "新增行程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTrip()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if !isEditing {
                    reminder = ReminderOption(rawValue: defaultReminder) ?? .none
                }
            }
        }
    }

    private func saveTrip() {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else {
            saveError = "请填写事项名称。"
            return
        }

        let normalizedLocation = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let trip: TripItem

        if let editingTrip {
            NotificationService.shared.cancelReminder(for: editingTrip.id)
            editingTrip.title = normalizedTitle
            editingTrip.startAt = startAt
            editingTrip.category = category
            editingTrip.locationName = normalizedLocation
            editingTrip.isReservation = isReservation
            editingTrip.notes = normalizedNotes
            editingTrip.reminder = reminder
            editingTrip.updatedAt = Date()
            trip = editingTrip
        } else {
            let newTrip = TripItem(
                title: normalizedTitle,
                startAt: startAt,
                category: category,
                locationName: normalizedLocation,
                isReservation: isReservation,
                notes: normalizedNotes,
                reminder: reminder
            )
            modelContext.insert(newTrip)
            trip = newTrip
        }

        Task {
            do {
                try await NotificationService.shared.scheduleReminder(for: trip)
            } catch {
                saveError = "行程已保存，但提醒创建失败。"
            }
        }

        dismiss()
    }
}

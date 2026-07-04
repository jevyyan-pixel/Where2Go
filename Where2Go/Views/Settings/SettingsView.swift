import SwiftData
import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TripItem.startAt) private var trips: [TripItem]

    @AppStorage("appearanceMode") private var appearanceMode = "system"
    @AppStorage("dailySummaryEnabled") private var dailySummaryEnabled = false
    @AppStorage("dailySummaryHour") private var dailySummaryHour = 8
    @AppStorage("dailySummaryMinute") private var dailySummaryMinute = 30
    @AppStorage("defaultReminder") private var defaultReminder = ReminderOption.none.rawValue

    @State private var notificationStatus = "检查中"
    @State private var pendingSummaryCount = 0
    @State private var exportURL: URL?
    @State private var exportError: String?
    @State private var isConfirmingClearAll = false

    var body: some View {
        NavigationStack {
            Form {
                Section("外观") {
                    Picker("模式", selection: $appearanceMode) {
                        Text("跟随系统").tag("system")
                        Text("浅色").tag("light")
                        Text("深色").tag("dark")
                    }
                }

                Section("提醒与摘要") {
                    Picker("默认提醒", selection: $defaultReminder) {
                        ForEach(ReminderOption.allCases) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }

                    Toggle("每日行程摘要", isOn: $dailySummaryEnabled)

                    DatePicker(
                        "摘要时间",
                        selection: summaryTimeBinding,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!dailySummaryEnabled)

                    LabeledContent("通知权限", value: notificationStatus)
                    LabeledContent("下一次摘要", value: dailySummaryEnabled ? nextSummaryDateText : "未开启")
                    LabeledContent("已排摘要", value: "\(pendingSummaryCount) 条")

                    Button {
                        refreshNotificationState()
                    } label: {
                        Label("刷新通知状态", systemImage: "arrow.clockwise")
                    }

                    Button {
                        openSystemSettings()
                    } label: {
                        Label("打开系统通知设置", systemImage: "gearshape")
                    }
                }

                Section("地图与隐私") {
                    LabeledContent("地图能力", value: "V0.1 暂不启用")
                    LabeledContent("数据存储", value: "仅本地")
                    LabeledContent("云同步", value: "暂不启用")
                }

                Section("数据") {
                    LabeledContent("行程数量", value: "\(trips.count)")

                    Button {
                        prepareExport()
                    } label: {
                        Label("生成 JSON 备份", systemImage: "square.and.arrow.up")
                    }
                    .disabled(trips.isEmpty)

                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Label("分享备份文件", systemImage: "doc")
                        }
                    }

                    if let exportError {
                        Text(exportError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button(role: .destructive) {
                        isConfirmingClearAll = true
                    } label: {
                        Label("清空全部行程", systemImage: "trash")
                    }
                    .disabled(trips.isEmpty)
                }

                Section("关于") {
                    LabeledContent("应用", value: "Where2Go")
                    LabeledContent("版本", value: "0.1")
                    LabeledContent("最低系统", value: "iOS 17")
                }
            }
            .navigationTitle("设置")
            .scrollContentBackground(.hidden)
            .background(DesignTokens.softBackground)
            .tint(DesignTokens.accent)
            .task {
                refreshNotificationState()
            }
            .onChange(of: dailySummaryEnabled) { _, _ in
                refreshNotificationState()
            }
            .confirmationDialog("确定清空全部行程吗？", isPresented: $isConfirmingClearAll, titleVisibility: .visible) {
                Button("清空", role: .destructive) {
                    clearAllTrips()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("此操作会删除本机保存的所有行程，并取消对应提醒。")
            }
        }
    }

    private var summaryTimeBinding: Binding<Date> {
        Binding {
            Calendar.current.date(bySettingHour: dailySummaryHour, minute: dailySummaryMinute, second: 0, of: Date()) ?? Date()
        } set: { newDate in
            let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
            dailySummaryHour = components.hour ?? 8
            dailySummaryMinute = components.minute ?? 30
        }
    }

    private var nextSummaryDateText: String {
        let calendar = Calendar.current
        let now = Date()
        let todaySummary = calendar.date(bySettingHour: dailySummaryHour, minute: dailySummaryMinute, second: 0, of: now) ?? now
        let nextDate = todaySummary > now ? todaySummary : (calendar.date(byAdding: .day, value: 1, to: todaySummary) ?? todaySummary)
        return nextDate.formatted(.dateTime.month().day().hour().minute())
    }

    private func refreshNotificationState() {
        Task {
            let status = await NotificationService.shared.authorizationStatus()
            let count = await NotificationService.shared.pendingDailySummaryCount()
            await MainActor.run {
                notificationStatus = status.localizedTitle
                pendingSummaryCount = count
            }
        }
    }

    private func prepareExport() {
        do {
            exportURL = try TripExportService.exportJSON(from: trips)
            exportError = nil
        } catch {
            exportURL = nil
            exportError = "导出失败：\(error.localizedDescription)"
        }
    }

    private func clearAllTrips() {
        for trip in trips {
            NotificationService.shared.cancelReminder(for: trip.id)
            modelContext.delete(trip)
        }
        Task {
            await NotificationService.shared.cancelDailySummaries()
            await MainActor.run {
                exportURL = nil
                refreshNotificationState()
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

private extension UNAuthorizationStatus {
    var localizedTitle: String {
        switch self {
        case .notDetermined:
            "未请求"
        case .denied:
            "已拒绝"
        case .authorized:
            "已允许"
        case .provisional:
            "临时允许"
        case .ephemeral:
            "临时会话"
        @unknown default:
            "未知"
        }
    }
}

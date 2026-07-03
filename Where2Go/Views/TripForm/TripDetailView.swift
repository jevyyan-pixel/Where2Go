import SwiftData
import SwiftUI

struct TripDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let trip: TripItem

    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Label {
                        Text(trip.category.title)
                            .font(.subheadline.weight(.semibold))
                    } icon: {
                        Image(systemName: trip.category.symbolName)
                    }
                    .foregroundStyle(trip.category.tint)

                    Text(trip.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(3)

                    Text(trip.startAt.formatted(.dateTime.year().month().day().weekday(.wide).hour().minute()))
                        .font(.headline)
                        .foregroundStyle(DesignTokens.accent)
                }
                .padding(.vertical, 8)
            }

            Section("地点与预约") {
                detailRow(title: "地点", value: trip.locationName.isEmpty ? "未设置" : trip.locationName, systemImage: "mappin.and.ellipse")
                detailRow(title: "预约", value: trip.isReservation ? "已预约" : "无需预约", systemImage: trip.isReservation ? "checkmark.seal.fill" : "circle")
            }

            Section("提醒") {
                detailRow(title: "提醒时间", value: trip.reminder.title, systemImage: "bell")
            }

            if !trip.notes.isEmpty {
                Section("备注") {
                    Text(trip.notes)
                        .foregroundStyle(.primary)
                }
            }

            Section {
                Button(role: .destructive) {
                    isConfirmingDelete = true
                } label: {
                    Label("删除行程", systemImage: "trash")
                }
            }
        }
        .navigationTitle("行程详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            TripFormView(trip: trip)
                .presentationDetents([.large])
        }
        .confirmationDialog("确定删除这个行程吗？", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                deleteTrip()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("删除后无法撤销。")
        }
    }

    private func detailRow(title: String, value: String, systemImage: String) -> some View {
        LabeledContent {
            Text(value)
                .foregroundStyle(value == "未设置" ? .secondary : .primary)
        } label: {
            Label(title, systemImage: systemImage)
        }
    }

    private func deleteTrip() {
        NotificationService.shared.cancelReminder(for: trip.id)
        modelContext.delete(trip)
        dismiss()
    }
}

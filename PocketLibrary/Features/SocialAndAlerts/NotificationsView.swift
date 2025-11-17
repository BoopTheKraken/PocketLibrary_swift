//  NotificationsView.swift
//  PocketLibrary

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @State private var enabled = true
    @State private var sampleBook = Book(
        id: .init(),
        title: "Dune",
        author: "Frank Herbert",
        genre: "Sci-Fi",
        isbn: "",
        isBorrowed: true
    )

    var body: some View {
        Form {
            Section("Due date reminders") {
                Toggle("Enable reminders", isOn: $enabled)

                Button("Schedule Due Reminder (Demo)") {
                    requestPermissionIfNeeded()
                    if enabled {
                        DueDateNotifier.scheduleDueSoon(for: sampleBook, secondsFromNow: 5)
                    }
                }
            }

            Section(footer: Text("In a real app, this would trigger reminders based on the actual due date from the library API.")) {
                EmptyView()
            }
        }
        .navigationTitle("Notifications")
    }

    private func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            }
        }
    }
}

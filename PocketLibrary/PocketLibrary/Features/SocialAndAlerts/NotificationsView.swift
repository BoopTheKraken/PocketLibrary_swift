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
            Section(header: Text("Due date reminders")) {
                Toggle("Enable reminders", isOn: $enabled)

                Button("Schedule Due Reminder (Demo)") {
                    Task { await requestPermissionIfNeeded() }
                    if enabled { scheduleDemoReminder(for: sampleBook, secondsFromNow: 5) }
                }
            }

            Section(footer: Text("In a real app, this would trigger reminders based on the actual due date from the library API.")) {
                EmptyView()
            }
        }
        .navigationTitle("Notifications")
    }

    private func requestPermissionIfNeeded() async {
        _ = await DueDateNotifier.requestPermission()
    }

    private func scheduleDemoReminder(for book: Book, secondsFromNow: TimeInterval) {
        DueDateNotifier.scheduleDueSoon(for: book, secondsFromNow: secondsFromNow)
    }
}

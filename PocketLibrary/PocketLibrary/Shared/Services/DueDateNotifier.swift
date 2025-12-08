//
//  DueDateNotifier.swift
//  PocketLibrary
//
//  Local notification helper for due date reminders.
//

import Foundation
import UserNotifications

enum DueDateNotifier {
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                return granted
            } catch {
                print("Notification authorization request failed: \(error)")
                return false
            }
        case .authorized, .provisional:
            return true
        default:
            return false
        }
    }

    static func scheduleDueSoon(for book: Book, secondsFromNow: TimeInterval = 48 * 3_600) {
        let content = UNMutableNotificationContent()
        content.title = "Book Due Soon!"
        content.body  = "Your copy of \(book.title) is due soon."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsFromNow, repeats: false)
        let request = UNNotificationRequest(
            identifier: book.id.uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}

//
//  DueDateNotifier.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

// local notifications

// Notifications
import UserNotifications
enum DueDateNotifier {
    static func scheduleDueSoon(for book: Book, secondsFromNow: TimeInterval = 48*3600) {
        let content = UNMutableNotificationContent()
        content.title = "Book Due Soon!"
        content.body  = "Your copy of \(book.title) is due in 2 days."
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsFromNow, repeats: false)
        let request = UNNotificationRequest(identifier: book.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

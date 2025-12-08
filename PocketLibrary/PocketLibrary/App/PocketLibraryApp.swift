//
//  PocketLibraryApp.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI
import SwiftData
import UIKit
import UserNotifications

// MARK: - Pocket Library App
@main
struct PocketLibraryApp: App {
    
    // MARK: - SwiftData Container
    let container = DataService.container
    
    // MARK: - Initialization
    init() {
        // Configure app appearance
        configureAppearance()
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .tint(Color.brandPrimary)
                .preferredColorScheme(nil) // System dark mode
                .toastView()
                .task { await requestNotificationPermissions() }
                .task { await seedDataIfNeeded() }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func requestNotificationPermissions() async {
        let granted = await DueDateNotifier.requestPermission()
        if granted {
            print("Notification permissions granted")
        } else {
            print("Notification permissions denied")
        }
    }
    
    @MainActor
    private func seedDataIfNeeded() async {
        let context = container.mainContext
        DataService.shared.seedSampleDataIfNeeded(context: context)
    }
}

import Foundation
import SwiftData

// MARK: - Temporary Data Service (replace later with real implementation)
@Model
final class _TempModel {
    var createdAt: Date

    init(createdAt: Date = Date()) {
        self.createdAt = createdAt
    }
}

final class DataService {
    static let shared = DataService()

    // In‑memory container so the app can run without a full model schema.
    // Replace `_TempModel.self` with a real @Model types and remove `isStoredInMemoryOnly`
    // once we are ready to persist on device.
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: _TempModel.self, configurations: config)
        } catch {
            fatalError("Failed to create in-memory ModelContainer: \(error)")
        }
    }()

    // Seed initial/sample data if needed. No‑op placeholder for now.
    func seedSampleDataIfNeeded(context: ModelContext) {
        // TODO: implement seeding for real models when available.
        // Example:
        // if try? context.fetch(FetchDescriptor<MyModel>()).isEmpty == true { ... }
    }
}

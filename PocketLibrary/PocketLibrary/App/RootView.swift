//
//  RootView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI
import SwiftData

// MARK: - Root View
/// Main TabView navigation for the app
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedTab") private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Library (Home)
            LibraryTab()
                .tabItem {
                    Label("Library", systemImage: "building.columns.fill")
                }
                .tag(0)
            
            // Tab 2: Discover (Tatiana's features)
            DiscoverTab()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
                .tag(1)
            
            // Tab 3: Activity (Social & Alerts)
            ActivityTab()
                .tabItem {
                    Label("Activity", systemImage: "star.fill")
                }
                .tag(2)
            
            // Tab 4: Account (Settings & Profile)
            AccountTab()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Color.brandPrimary)
    }
}

// MARK: - Tab 1: Library
struct LibraryTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Quick Actions
                    QuickActionsSection()
                    
                    // Main Features
                    VStack(spacing: Spacing.standard) {
                        FeatureNavigationCard(
                            title: "Search Books",
                            subtitle: "Find available books nearby",
                            icon: "magnifyingglass",
                            color: .blue,
                            destination: PlaceholderScreen(title: "Search Books", description: "Search and filter the catalog. Coming soon.")
                        )
                        
                        FeatureNavigationCard(
                            title: "My Reservations",
                            subtitle: "View your reserved books",
                            icon: "bookmark.fill",
                            color: .purple,
                            destination: PlaceholderScreen(title: "My Reservations", description: "Manage current and past reservations. Coming soon.")
                        )
                        
                        FeatureNavigationCard(
                            title: "Reading Goals",
                            subtitle: "Track your progress",
                            icon: "target",
                            color: .green,
                            destination: PlaceholderScreen(title: "Reading Goals", description: "Set goals and track streaks. Coming soon.")
                        )
                    }
                    .padding(.horizontal, Spacing.standard)
                }
                .padding(.vertical, Spacing.standard)
            }
            .background(Color.bg)
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Tab 2: Discover
struct DiscoverTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.standard) {
                    FeatureNavigationCard(
                        title: "Browse by Genre",
                        subtitle: "Explore our collection",
                        icon: "books.vertical.fill",
                        color: .orange,
                        destination: PlaceholderScreen(title: "Browse by Genre", description: "Browse genres and curated shelves. Coming soon.")
                    )
                    
                    FeatureNavigationCard(
                        title: "Recommended for You",
                        subtitle: "Personalized suggestions",
                        icon: "sparkles",
                        color: .pink,
                        destination: PlaceholderScreen(title: "Recommendations", description: "Smart picks based on your history. Coming soon.")
                    )
                    
                    FeatureNavigationCard(
                        title: "Library Card",
                        subtitle: "Your digital ID card",
                        icon: "qrcode",
                        color: .teal,
                        destination: PlaceholderScreen(title: "Library Card", description: "Your digital QR code card. Coming soon.")
                    )
                    
                    FeatureNavigationCard(
                        title: "Find Branches",
                        subtitle: "Locate nearby libraries",
                        icon: "map.fill",
                        color: .cyan,
                        destination: PlaceholderScreen(title: "Find Branches", description: "Map and branch details. Coming soon.")
                    )
                }
                .padding(Spacing.standard)
            }
            .background(Color.bg)
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Tab 3: Activity
struct ActivityTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.standard) {
                    FeatureNavigationCard(
                        title: "Book Reviews",
                        subtitle: "Share your thoughts",
                        icon: "text.bubble.fill",
                        color: .indigo,
                        destination: PlaceholderScreen(title: "Book Reviews", description: "Write and read reviews. Coming soon.")
                    )
                    
                    FeatureNavigationCard(
                        title: "Achievements",
                        subtitle: "Your reading milestones",
                        icon: "trophy.fill",
                        color: Color(red: 1.0, green: 0.84, blue: 0.0),
                        destination: PlaceholderScreen(title: "Achievements", description: "Earn badges and track milestones. Coming soon.")
                    )
                    
                    FeatureNavigationCard(
                        title: "Notifications",
                        subtitle: "Due date reminders",
                        icon: "bell.fill",
                        color: .red,
                        destination: PlaceholderScreen(title: "Notifications", description: "Manage alerts and reminders. Coming soon.")
                    )
                }
                .padding(Spacing.standard)
            }
            .background(Color.bg)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Tab 4: Account
struct AccountTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Profile Card
                    ProfileCard()
                    
                    // Features
                    VStack(spacing: Spacing.standard) {
                        FeatureNavigationCard(
                            title: "Fines & Payments",
                            subtitle: "Manage your account",
                            icon: "creditcard.fill",
                            color: .green,
                            destination: PlaceholderScreen(title: "Fines & Payments", description: "Pay fines and view history. Coming soon.")
                        )
                    }
                    .padding(.horizontal, Spacing.standard)
                    
                    // Settings Section
                    SettingsSection()
                }
                .padding(.vertical, Spacing.standard)
            }
            .background(Color.bg)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Placeholder Screen
struct PlaceholderScreen: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: Spacing.large) {
            Image(systemName: "hammer")
                .font(.system(size: 56, weight: .regular))
                .foregroundStyle(Color.secondaryFg)
                .padding(.top, Spacing.extraLarge)
            
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.fg)
            
            Text(description)
                .font(.body)
                .foregroundStyle(Color.secondaryFg)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.extraLarge)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bg)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Components

// MARK: Quick Actions
struct QuickActionsSection: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Quick Actions")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondaryFg)
                .padding(.horizontal, Spacing.standard)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.standard) {
                    QuickActionButton(icon: "qrcode", title: "Scan Card", color: .teal) {
                        selectedTab = 1
                    }
                    
                    QuickActionButton(icon: "map.fill", title: "Find Branch", color: .cyan) {
                        selectedTab = 1
                    }
                    
                    QuickActionButton(icon: "creditcard.fill", title: "Pay Fines", color: .green) {
                        selectedTab = 3
                    }
                }
                .padding(.horizontal, Spacing.standard)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.small) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }
                .frame(width: 56, height: 56)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.fg)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 80)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: Feature Navigation Card
struct FeatureNavigationCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: Spacing.standard) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }
                .frame(width: 50, height: 50)
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.fg)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryFg)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryFg)
            }
            .padding(Spacing.standard)
            .background(Color.secondaryBg)
            .cornerRadius(CornerRadius.medium)
            .shadow(color: Color.cardShadow, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: Profile Card
struct ProfileCard: View {
    @AppStorage("userName") private var userName = "Library Member"
    @AppStorage("userLibraryID") private var userLibraryID = "LBR-1234-5678"
    
    var body: some View {
        HStack(spacing: Spacing.standard) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPrimary.opacity(0.6), Color.brandPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }
            .frame(width: 60, height: 60)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.fg)
                
                Text("ID: \(userLibraryID)")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryFg)
                    .monospaced()
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.secondaryFg)
        }
        .padding(Spacing.standard)
        .background(Color.secondaryBg)
        .cornerRadius(CornerRadius.medium)
        .shadow(color: Color.cardShadow, radius: 2, x: 0, y: 1)
        .padding(.horizontal, Spacing.standard)
    }
}

// MARK: Settings Section
struct SettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Settings")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondaryFg)
                .padding(.horizontal, Spacing.standard)
            
            VStack(spacing: 0) {
                SettingsRow(icon: "moon.fill", title: "Dark Mode", subtitle: "Automatic (System)", color: .purple)
                
                Divider().padding(.leading, 60)
                
                SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Enabled", color: .red)
                
                Divider().padding(.leading, 60)
                
                SettingsRow(icon: "accessibility", title: "Accessibility", subtitle: "Text size: Medium", color: .blue)
            }
            .background(Color.secondaryBg)
            .cornerRadius(CornerRadius.medium)
            .padding(.horizontal, Spacing.standard)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.standard) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
            }
            .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color.fg)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryFg)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.secondaryFg)
        }
        .padding(Spacing.standard)
    }
}

// MARK: - Preview
#Preview {
    RootView()
        .modelContainer(DataService.container)
}

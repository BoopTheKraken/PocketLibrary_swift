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
    @StateObject private var reservationVM = ReservationViewModel()
    @AppStorage("selectedTab") private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Library (Home)
            LibraryTab(reservationVM: reservationVM)
                .tabItem {
                    Label("Library", systemImage: "building.columns.fill")
                }
                .tag(0)
            
            // Tab 2: Discover (Tatiana's features)
            DiscoverTab(reservationVM: reservationVM)
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
    @ObservedObject var reservationVM: ReservationViewModel
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section with Library Image
                    LibraryHeroSection()

                    VStack(spacing: Spacing.large) {
                        // Quick Actions
                        QuickActionsSection()

                        // Main Features
                        VStack(spacing: Spacing.standard) {
                        FeatureNavigationCard(
                            title: "Search & Discover",
                            subtitle: "Find books and check availability",
                            icon: "magnifyingglass",
                            color: .featureBlue,
                            destination: SearchView(reservationVM: reservationVM)
                        )

                            FeatureNavigationCard(
                                title: "My Reservations",
                                subtitle: "View your reserved books",
                                icon: "bookmark.fill",
                                color: .featurePurple,
                                destination: ReservationView(reservationVM: reservationVM)
                            )

                            FeatureNavigationCard(
                                title: "Reading Goals",
                                subtitle: "Track your progress",
                                icon: "target",
                                color: .featureGreen,
                                destination: ReadingGoalsView()
                            )
                        }
                        .padding(.horizontal, Spacing.standard)
                    }
                    .padding(.vertical, Spacing.standard)
                }
            }
            .background(Color.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Empty - title hidden when at top
                    Text("")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Tab 2: Discover
struct DiscoverTab: View {
    @ObservedObject var reservationVM: ReservationViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.standard) {
                    FeatureNavigationCard(
                        title: "Recommended for You",
                        subtitle: "Personalized suggestions",
                        icon: "sparkles",
                        color: .featurePink,
                        destination: RecommendationsView(
                            recentlyViewed: Array(MockLibraryAPI.sampleBooks.prefix(2)),
                            allBooks: MockLibraryAPI.sampleBooks,
                            reservationVM: reservationVM
                        )
                    )

                    FeatureNavigationCard(
                        title: "Library Card",
                        subtitle: "Your digital ID card",
                        icon: "qrcode",
                        color: .featureTeal,
                        destination: QRCardView()
                    )

                    FeatureNavigationCard(
                        title: "Find Branches",
                        subtitle: "Locate nearby libraries",
                        icon: "map.fill",
                        color: .featureCyan,
                        destination: BranchMapView()
                    )
                }
                .padding(Spacing.standard)
            }
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Tab 3: Activity
struct ActivityTab: View {
    private let sampleBook = MockLibraryAPI.sampleBooks.first ?? Book(
        title: "Dune",
        author: "Frank Herbert",
        genre: "Sci-Fi",
        isbn: "9780441172719",
        isBorrowed: false
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.standard) {
                    FeatureNavigationCard(
                        title: "Book Reviews",
                        subtitle: "Share your thoughts",
                        icon: "text.bubble.fill",
                        color: .featureIndigo,
                        destination: ReviewsView(book: sampleBook)
                    )

                    FeatureNavigationCard(
                        title: "Reading Stats",
                        subtitle: "Progress and achievements",
                        icon: "chart.bar.fill",
                        color: .featureGold,
                        destination: ReadingStatsView()
                    )

                    FeatureNavigationCard(
                        title: "Notifications",
                        subtitle: "Due date reminders",
                        icon: "bell.fill",
                        color: .featureRed,
                        destination: NotificationsView()
                    )
                }
                .padding(Spacing.standard)
            }
            .background(Color.bg.ignoresSafeArea())
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
                            color: .featureGreen,
                            destination: PaymentsView()
                        )
                    }
                    .padding(.horizontal, Spacing.standard)
                    
                    // Settings Section
                    SettingsSection()
                }
                .padding(.vertical, Spacing.standard)
            }
            .background(Color.bg.ignoresSafeArea())
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

// MARK: Library Hero Section with Parallax
struct LibraryHeroSection: View {
    @AppStorage("userName") private var userName = "Library Member"

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Layer 1: Background Image
            GeometryReader { geometry in
                let offset = geometry.frame(in: .global).minY

                Image("library_hero")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 240 + max(0, offset))
                    .offset(y: -max(0, offset))
                    .clipped()
                    .accessibilityHidden(true)
            }

            // Layer 2: Gradient overlay at the bottom for text readability
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.black.opacity(0.85), location: 0.0),
                        .init(color: Color.black.opacity(0.65), location: 0.3),
                        .init(color: Color.black.opacity(0.3), location: 0.6),
                        .init(color: Color.clear, location: 0.9)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 110)
            }
            .allowsHitTesting(false)

            // Layer 3: Hero Content with fade effect
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)

                Text(userName)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)

                Text("Discover your next great read")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
            }
            .padding(Spacing.large)
            .padding(.bottom, Spacing.small)
        }
        .frame(height: 240)
        .clipped()
    }
}

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
                    QuickActionButton(icon: "qrcode", title: "Scan Card", color: .featureTeal) {
                        selectedTab = 1
                    }

                    QuickActionButton(icon: "map.fill", title: "Find Branch", color: .featureCyan) {
                        selectedTab = 1
                    }

                    QuickActionButton(icon: "creditcard.fill", title: "Pay Fines", color: .featureGreen) {
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
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.2),
                                    color.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                        .accessibilityHidden(true)
                }
                .frame(width: 56, height: 56)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.fg)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 80, alignment: .center)
            }
            .frame(width: 80, alignment: .center)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
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
                // Icon with modern gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.15),
                                    color.opacity(0.25)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                        .accessibilityHidden(true)
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
                    .accessibilityHidden(true)
            }
            .padding(Spacing.standard)
            .background(Color.secondaryBg)
            .cornerRadius(CornerRadius.medium)
            .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
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
            // Avatar with modern gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.brandPrimary.opacity(0.7),
                                Color.brandPrimary,
                                Color.featurePurple
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.brandPrimary.opacity(0.3), radius: 8, x: 0, y: 4)

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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.secondaryBg,
                    Color.secondaryBg.opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(CornerRadius.medium)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
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
                SettingsRow(icon: "moon.fill", title: "Dark Mode", subtitle: "Automatic (System)", color: .featurePurple)
                
                Divider().padding(.leading, 60)

                SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Enabled", color: .featureRed)

                Divider().padding(.leading, 60)

                SettingsRow(icon: "accessibility", title: "Accessibility", subtitle: "Text size: Medium", color: .featureBlue)
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

//
//  Theme.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//


import SwiftUI
import UIKit

// MARK: - Design Tokens

enum Spacing {
    static let small: CGFloat = 8
    static let standard: CGFloat = 12
    static let large: CGFloat = 20
    static let extraLarge: CGFloat = 28
}

enum CornerRadius {
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
}

// Color palette used across the app.
extension Color {
    static let brandPrimary   = Color.blue
    static let accent         = Color.brandPrimary
    static let bg             = Color(UIColor.systemBackground)
    static let secondaryBg    = Color(UIColor.secondarySystemBackground)
    static let fg             = Color.primary
    static let secondaryFg    = Color.secondary
    static let cardShadow     = Color.black.opacity(0.08)

    // Semantic feature colors (use these instead of hardcoded colors)
    static let featureBlue    = Color.blue
    static let featureIndigo  = Color.indigo
    static let featurePurple  = Color.purple
    static let featureGreen   = Color.green
    static let featureOrange  = Color.orange
    static let featurePink    = Color.pink
    static let featureTeal    = Color.teal
    static let featureCyan    = Color.cyan
    static let featureRed     = Color.red
    static let featureGold    = Color(red: 1.0, green: 0.84, blue: 0.0)

    // Asset Catalog colors (for apps with custom design)
    static let appBackground  = Color("BackgroundColor")
    static let appText        = Color("TextColor")
    static let appAccent      = Color("AccentColor")
}

// MARK: - Haptics

enum HapticFeedback {
    case light
    case success
    case error

    func trigger() {
        switch self {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color.accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .shadow(color: Color.cardShadow, radius: 6, x: 0, y: 3)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    var colors: [Color]

    @State private var start = UnitPoint(x: 0, y: 0)
    @State private var end   = UnitPoint(x: 1, y: 1)

    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: start,
                       endPoint: end)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                start = UnitPoint(x: 1, y: 0)
                end   = UnitPoint(x: 0, y: 1)
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    
    var body: some View {
        if isActive {
            RootView()
        } else {
            ZStack {
                AnimatedGradientBackground(colors: [
                    Color.accent.opacity(0.8),
                    Color.purple.opacity(0.6),
                    Color.pink.opacity(0.8)
                ])
                
                VStack(spacing: Spacing.large) {
                    // Logo
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    Text("PocketLibrary")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(logoOpacity)
                    
                    Text("Your Library in Your Pocket")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .opacity(logoOpacity)
                }
            }
            .onAppear {
                // Logo animation
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                
                // Navigate to main app
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "magnifyingglass",
            title: "Discover Books",
            description: "Search and browse thousands of books by genre, author, or title",
            color: .blue
        ),
        OnboardingPage(
            icon: "qrcode",
            title: "Digital Library Card",
            description: "Access your library card anytime with a QR code",
            color: .teal
        ),
        OnboardingPage(
            icon: "map.fill",
            title: "Find Branches",
            description: "Locate nearby library branches with real-time availability",
            color: .green
        ),
        OnboardingPage(
            icon: "star.fill",
            title: "Track Progress",
            description: "Set reading goals and earn achievements",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            Color.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation {
                            hasSeenOnboarding = true
                        }
                    }
                    .foregroundStyle(Color.accent)
                    .padding()
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Action buttons
                VStack(spacing: Spacing.standard) {
                    if currentPage == pages.count - 1 {
                        Button("Get Started") {
                            withAnimation {
                                hasSeenOnboarding = true
                                HapticFeedback.success.trigger()
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    } else {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                                HapticFeedback.light.trigger()
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(Spacing.large)
            }
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: Spacing.extraLarge) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 180, height: 180)
                
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(page.color)
            }
            .scaleEffect(appear ? 1.0 : 0.5)
            .opacity(appear ? 1.0 : 0.0)
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.fg)
                .multilineTextAlignment(.center)
                .offset(y: appear ? 0 : 20)
                .opacity(appear ? 1.0 : 0.0)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundStyle(Color.secondaryFg)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.extraLarge)
                .offset(y: appear ? 0 : 20)
                .opacity(appear ? 1.0 : 0.0)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                appear = true
            }
        }
        .onDisappear {
            appear = false
        }
    }
}

// MARK: - App Entry with Splash
struct AppEntryView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        if hasSeenOnboarding {
            SplashScreen()
        } else {
            OnboardingView()
        }
    }
}

// MARK: - Accessible Text Modifier

struct AccessibleText: ViewModifier {
    @Environment(\.sizeCategory) private var sizeCategory

    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(0.9)
            .accessibilityAddTraits(.isStaticText)
    }
}

extension View {
    func accessible() -> some View {
        modifier(AccessibleText())
    }
}

// MARK: - Theming Helpers

enum AppTheme {
    static func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.fg)
            .accessible()
    }
}

// MARK: - Preview
#Preview("Splash Screen") {
    SplashScreen()
}

#Preview("Onboarding") {
    OnboardingView()
}

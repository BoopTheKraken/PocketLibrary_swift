//
// theme.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//
// Modified by Yuchen Chung 11/30/25

import SwiftUI

// MARK: - App Colors

extension Color {
    // Define in Assets.xcassets (light/dark variants)
    static let appBackground = Color("BackgroundColor")
    static let appText       = Color("TextColor")
    static let appAccent     = Color("AccentColor")
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

// MARK: - Optional: Theming Helpers

enum AppTheme {
    static func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.appText)
            .accessible()
    }
}

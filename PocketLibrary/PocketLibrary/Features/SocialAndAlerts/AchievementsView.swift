//  AchievementsView.swift
//  PocketLibrary

import SwiftUI

struct AchievementsView: View {
    @AppStorage("streakDays") private var streakDays = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Achievements")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.fg)

                        Text("Track your reading streak and celebrate your progress over time.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryFg)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Streak card
                    VStack(spacing: Spacing.standard) {
                        Text("Reading Streak")
                            .font(.headline)
                            .foregroundStyle(Color.fg)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("\(streakDays) days")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.accent)

                        Button("Add a day") {
                            streakDays += 1
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(Spacing.large)
                    .background(Color.secondaryBg)
                    .cornerRadius(CornerRadius.medium)
                    .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)

                    // Info text
                    Text("In a real app, your streak would update automatically based on your completed reading sessions and finished books.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryFg)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Spacing.large)
            }
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

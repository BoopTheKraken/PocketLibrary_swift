//  AchievementsView.swift
//  PocketLibrary

import SwiftUI

struct AchievementsView: View {
    @AppStorage("streakDays") private var streakDays = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Reading Streak")
                .font(.title2)
                .bold()

            Text("\(streakDays) days!")
                .font(.title3)

            Button("Add a day") {
                streakDays += 1
            }
            .buttonStyle(.borderedProminent)

            Text("In a real app, this would update automatically based on your reading activity.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
        .navigationTitle("Achievements")
    }
}

//
//  ReadingGoalsView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//
import SwiftUI

struct ReadingGoalsView: View {
    @AppStorage("goalBooks") private var goalBooks: Double = 12
    @AppStorage("booksRead") private var booksRead: Double = 0

    private var progress: Double {
        guard goalBooks > 0 else { return 0 }
        return min(booksRead / goalBooks, 1.0)
    }

    private var progressText: String {
        "You've read \(Int(booksRead)) of \(Int(goalBooks)) books!"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reading Goal")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.fg)

                        Text("Set a yearly goal and track how many books you've completed.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryFg)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Progress Card
                    VStack(spacing: Spacing.standard) {
                        Text(progressText)
                            .font(.headline)
                            .foregroundStyle(Color.fg)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ProgressView(value: progress) {
                            EmptyView()
                        }
                        .progressViewStyle(.linear)

                        HStack {
                            Text("0")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryFg)
                            Spacer()
                            Text("\(Int(goalBooks))")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryFg)
                        }
                    }
                    .padding(Spacing.large)
                    .background(Color.secondaryBg)
                    .cornerRadius(CornerRadius.medium)
                    .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)

                    // Controls Card
                    VStack(spacing: Spacing.standard) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Goal")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.fg)

                            Stepper("Target: \(Int(goalBooks)) books", value: $goalBooks, in: 1...100)
                                .font(.body)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.fg)

                            Stepper("Completed: \(Int(booksRead)) books", value: $booksRead, in: 0...100)
                                .font(.body)
                        }
                    }
                    .padding(Spacing.large)
                    .background(Color.secondaryBg)
                    .cornerRadius(CornerRadius.medium)
                    .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)

                    Spacer(minLength: Spacing.large)
                }
                .padding(Spacing.large)
            }
            .background(Color.bg)
            .navigationTitle("Reading Goals")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    ReadingGoalsView()
        .modelContainer(DataService.container)
}

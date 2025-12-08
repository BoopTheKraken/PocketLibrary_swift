//
//  ReadingStatsView.swift
//  PocketLibrary
//
//  Reading statistics and progress visualization
//

import SwiftUI
import Charts

struct ReadingStatsView: View {
    @AppStorage("booksReadThisYear") private var booksReadThisYear = 12
    @AppStorage("readingGoal") private var readingGoal = 24
    @AppStorage("currentStreak") private var currentStreak = 7

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Reading Goal Progress
                ReadingGoalCard(booksRead: booksReadThisYear, goal: readingGoal)

                // Books Read Over Time
                BooksReadChartCard()

                // Genre Breakdown
                GenreBreakdownCard()

                // Reading Streak
                ReadingStreakCard(currentStreak: currentStreak)
            }
            .padding(Spacing.standard)
        }
        .background(Color.bg.ignoresSafeArea())
        .navigationTitle("Reading Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Reading Goal Card
struct ReadingGoalCard: View {
    let booksRead: Int
    let goal: Int

    var progress: Double {
        Double(booksRead) / Double(goal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            Text("2025 Reading Goal")
                .font(.headline)
                .foregroundStyle(Color.fg)

            HStack(alignment: .bottom, spacing: Spacing.small) {
                Text("\(booksRead)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.featureBlue)

                Text("/ \(goal) books")
                    .font(.title3)
                    .foregroundStyle(Color.secondaryFg)
                    .padding(.bottom, Spacing.small)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondaryBg)
                        .frame(height: 12)

                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.featureBlue, Color.featurePurple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 12)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 12)

            Text("\(Int(progress * 100))% complete • \(goal - booksRead) books to go")
                .font(.caption)
                .foregroundStyle(Color.secondaryFg)
        }
        .padding(Spacing.large)
        .background(Color.secondaryBg)
        .cornerRadius(CornerRadius.large)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Books Read Chart
struct BooksReadChartCard: View {
    let monthlyData = [
        MonthReading(month: "Jan", books: 2),
        MonthReading(month: "Feb", books: 3),
        MonthReading(month: "Mar", books: 1),
        MonthReading(month: "Apr", books: 2),
        MonthReading(month: "May", books: 1),
        MonthReading(month: "Jun", books: 3)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            Text("Books Read This Year")
                .font(.headline)
                .foregroundStyle(Color.fg)

            Chart(monthlyData) { item in
                BarMark(
                    x: .value("Month", item.month),
                    y: .value("Books", item.books)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.featureBlue.opacity(0.8), Color.featurePurple.opacity(0.8)]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(6)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(Spacing.large)
        .background(Color.secondaryBg)
        .cornerRadius(CornerRadius.large)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Genre Breakdown
struct GenreBreakdownCard: View {
    let genreData = [
        GenreReading(genre: "Fiction", books: 5, color: .featureBlue),
        GenreReading(genre: "Mystery", books: 3, color: .featurePurple),
        GenreReading(genre: "Sci-Fi", books: 2, color: .featureTeal),
        GenreReading(genre: "Non-Fiction", books: 2, color: .featureOrange)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            Text("Favorite Genres")
                .font(.headline)
                .foregroundStyle(Color.fg)

            Chart(genreData) { item in
                SectorMark(
                    angle: .value("Books", item.books),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .annotation(position: .overlay) {
                    Text("\(item.books)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
            }
            .frame(height: 200)

            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(genreData) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)

                        Text(item.genre)
                            .font(.caption)
                            .foregroundStyle(Color.fg)

                        Spacer()

                        Text("\(item.books) books")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryFg)
                    }
                }
            }
            .padding(.top, Spacing.small)
        }
        .padding(Spacing.large)
        .background(Color.secondaryBg)
        .cornerRadius(CornerRadius.large)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Reading Streak
struct ReadingStreakCard: View {
    let currentStreak: Int

    var body: some View {
        HStack(spacing: Spacing.large) {
            // Streak Number
            VStack(spacing: 4) {
                Text("\(currentStreak)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.featureOrange, Color.featureRed]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Day Streak")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryFg)
            }

            Divider()
                .frame(height: 60)

            // Encouragement
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(Color.featureOrange)

                Text("Keep it up!")
                    .font(.headline)
                    .foregroundStyle(Color.fg)

                Text("You're on fire! Read daily to maintain your streak.")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryFg)
                    .lineLimit(2)
            }
        }
        .padding(Spacing.large)
        .background(Color.secondaryBg)
        .cornerRadius(CornerRadius.large)
        .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Data Models
struct MonthReading: Identifiable {
    let id = UUID()
    let month: String
    let books: Int
}

struct GenreReading: Identifiable {
    let id = UUID()
    let genre: String
    let books: Int
    let color: Color
}

#Preview {
    NavigationStack {
        ReadingStatsView()
    }
}

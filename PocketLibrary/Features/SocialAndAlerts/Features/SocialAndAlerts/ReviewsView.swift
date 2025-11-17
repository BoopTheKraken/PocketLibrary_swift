//  ReviewsView.swift
//  PocketLibrary

import SwiftUI

struct ReviewsView: View {
    let book: Book

    @StateObject private var vm = ReviewsViewModel()

    // New review form state
    @State private var userName: String = ""
    @State private var rating: Int = 5
    @State private var comment: String = ""

    private let possibleRatings = [1, 2, 3, 4, 5]

    var body: some View {
        List {
            Section("\(book.title) Reviews") {
                if vm.isLoading {
                    ProgressView("Loading...")
                } else if vm.reviews.isEmpty {
                    Text("No reviews yet. Be the first to leave one!")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.reviews) { review in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(review.userName).bold()
                                Spacer()
                                Text("\(review.rating) ★")
                                    .font(.caption)
                            }
                            Text(review.comment)
                            Text(review.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("Add a Review") {
                TextField("Your name", text: $userName)

                Picker("Rating", selection: $rating) {
                    ForEach(possibleRatings, id: \.self) { value in
                        Text("\(value) ★").tag(value)
                    }
                }

                TextField("Write a short comment", text: $comment, axis: .vertical)
                    .lineLimit(2...4)

                Button("Submit Review") {
                    Task { await submitReview() }
                }
                .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty ||
                          comment.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Section("More Social Features") {
                NavigationLink("Notifications Settings") {
                    NotificationsView()
                }
                NavigationLink("Reading Achievements") {
                    AchievementsView()
                }
            }
        }
        .navigationTitle("Social")
        .task {
            await vm.load(for: book.id)
        }
    }

    private func submitReview() async {
        let newReview = Review(
            id: .init(),
            bookId: book.id,
            userName: userName.trimmingCharacters(in: .whitespaces),
            rating: rating,
            comment: comment.trimmingCharacters(in: .whitespaces),
            createdAt: Date()
        )

        await vm.add(review: newReview)
        userName = ""
        rating = 5
        comment = ""
    }
}

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
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""

    private let possibleRatings = [1, 2, 3, 4, 5]
    private let maxCommentLength = 500
    private let maxNameLength = 50

    var body: some View {
        List {
            Section(header: Text("\(book.title) Reviews")) {
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
                    .onChange(of: userName) { _, newValue in
                        if newValue.count > maxNameLength {
                            userName = String(newValue.prefix(maxNameLength))
                        }
                    }
                    .accessibilityHint("Enter your name, up to \(maxNameLength) characters")

                Picker("Rating", selection: $rating) {
                    ForEach(possibleRatings, id: \.self) { value in
                        Text("\(value) ★").tag(value)
                    }
                }
                .accessibilityLabel("Rating out of 5 stars")

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Write a short comment", text: $comment, axis: .vertical)
                        .lineLimit(2...4)
                        .onChange(of: comment) { _, newValue in
                            if newValue.count > maxCommentLength {
                                comment = String(newValue.prefix(maxCommentLength))
                            }
                        }
                        .accessibilityHint("Enter your review, up to \(maxCommentLength) characters")

                    Text("\(comment.count)/\(maxCommentLength)")
                        .font(.caption)
                        .foregroundStyle(comment.count > maxCommentLength * 9 / 10 ? Color.featureOrange : Color.secondary)
                }

                Button("Submit Review") {
                    if validateReview() {
                        Task { await submitReview() }
                    }
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
        .alert("Invalid Review", isPresented: $showingValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationErrorMessage)
        }
    }

    private func validateReview() -> Bool {
        let trimmedName = userName.trimmingCharacters(in: .whitespaces)
        let trimmedComment = comment.trimmingCharacters(in: .whitespaces)

        if trimmedName.isEmpty {
            validationErrorMessage = "Please enter your name."
            showingValidationError = true
            return false
        }

        if trimmedName.count < 2 {
            validationErrorMessage = "Your name must be at least 2 characters long."
            showingValidationError = true
            return false
        }

        if trimmedComment.isEmpty {
            validationErrorMessage = "Please enter a comment for your review."
            showingValidationError = true
            return false
        }

        if trimmedComment.count < 10 {
            validationErrorMessage = "Your comment must be at least 10 characters long."
            showingValidationError = true
            return false
        }

        return true
    }

    private func submitReview() async {
        let newReview = Review(
            id: UUID(),
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
        HapticFeedback.success.trigger()
    }
}

//  ReviewsViewModel.swift
//  PocketLibrary

import Foundation

@MainActor
final class ReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false

    private let api: LibraryAPI

    init(api: LibraryAPI = MockLibraryAPI()) {
        self.api = api
    }

    func load(for bookId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        reviews = (try? await api.fetchReviews(bookId: bookId)) ?? []
    }

    func add(review: Review) async {
        try? await api.addReview(review)
        reviews.insert(review, at: 0)
    }
}

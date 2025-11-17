//
//  RecommendationsView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

struct RecommendationsView: View {
    /// Books the user has recently viewed / borrowed.
    var recentlyViewed: [Book]

    /// All books available in the library (inject from Search/Availability later).
    var allBooks: [Book]

    /// Simple recommendation rule:
    /// - collect genres of recently viewed books
    /// - recommend other books with same genre that are not currently borrowed
    private var recommendations: [Book] {
        let genres = Set(recentlyViewed.map { $0.genre })
        guard !genres.isEmpty else { return [] }

        return allBooks
            .filter { genres.contains($0.genre) && $0.isBorrowed == false }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    var body: some View {
        Group {
            if recommendations.isEmpty {
                VStack(spacing: 12) {
                    Text("No Recommendations Yet")
                        .font(.title3)
                        .bold()
                    Text("Browse or borrow a few books and we’ll suggest similar titles here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(recommendations) { book in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.headline)
                        Text(book.author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(book.genre)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Recommended")
    }
}

#Preview {
    // Simple preview data so you can see the UI in Xcode
    let sampleBooks = [
        Book(id: UUID(), title: "Dune", author: "Frank Herbert", genre: "Sci-Fi", isbn: "1", isBorrowed: false),
        Book(id: UUID(), title: "Neuromancer", author: "William Gibson", genre: "Sci-Fi", isbn: "2", isBorrowed: false),
        Book(id: UUID(), title: "Pride and Prejudice", author: "Jane Austen", genre: "Romance", isbn: "3", isBorrowed: false),
        Book(id: UUID(), title: "Foundation", author: "Isaac Asimov", genre: "Sci-Fi", isbn: "4", isBorrowed: true)
    ]

    // Pretend user recently viewed Dune and Foundation (Sci-Fi)
    NavigationStack {
        RecommendationsView(
            recentlyViewed: Array(sampleBooks.prefix(2)),
            allBooks: sampleBooks
        )
    }
}


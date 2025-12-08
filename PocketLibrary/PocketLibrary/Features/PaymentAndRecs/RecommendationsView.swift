//
//  RecommendationsView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//
// Modified by Yuchen Chung 11/30/25

import SwiftUI

struct RecommendationsView: View {
    /// Inject these from Search/Availability when wiring up the app.
    let recentlyViewed: [Book]
    let allBooks: [Book]
    @ObservedObject var reservationVM: ReservationViewModel = ReservationViewModel()
    @StateObject private var availabilityVM = AvailabilityViewModel()
    @State private var showBranchesForBook: Book?

    private var recommendations: [Book] {
        let genres = Set(recentlyViewed.map { $0.genre })
        guard !genres.isEmpty else { return [] }

        return allBooks.filter { book in
            genres.contains(book.genre) && !book.isBorrowed
        }
    }

    var body: some View {
        Group {
            if recommendations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 40))
                    Text("No recommendations yet.")
                        .font(.title3)
                        .accessible()
                    Text("Start browsing books and we'll suggest similar titles here.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .accessible()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
            } else {
                List(recommendations) { book in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(book.title)
                            .font(.headline)
                            .accessible()

                        Text(book.author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .accessible()

                        Text(book.genre)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessible()

                        Button {
                            showBranchesFor(book)
                        } label: {
                            Label("Find nearby", systemImage: "location.viewfinder")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Recommended")
        .background(Color.bg.ignoresSafeArea())
        .sheet(item: $showBranchesForBook) { book in
            BranchesSheet(book: book, availabilityVM: availabilityVM, reservationVM: reservationVM)
                .presentationDetents([.medium, .large])
        }
    }

    private func showBranchesFor(_ book: Book) {
        showBranchesForBook = book
        Task { await availabilityVM.loadBranches(for: book) }
    }
}

#Preview {
    // Sample data for preview only
    let dune = Book(
        id: UUID(),
        title: "Dune",
        author: "Frank Herbert",
        genre: "Sci-Fi",
        isbn: "123",
        isBorrowed: true
    )
    let foundation = Book(
        id: UUID(),
        title: "Foundation",
        author: "Isaac Asimov",
        genre: "Sci-Fi",
        isbn: "456",
        isBorrowed: false
    )
    let pride = Book(
        id: UUID(),
        title: "Pride and Prejudice",
        author: "Jane Austen",
        genre: "Fiction",
        isbn: "789",
        isBorrowed: false
    )

    return NavigationStack {
        RecommendationsView(
            recentlyViewed: [dune],
            allBooks: [dune, foundation, pride],
            reservationVM: ReservationViewModel()
        )
    }
}

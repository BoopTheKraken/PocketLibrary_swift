//
//  BrowseByGenreView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

@MainActor
final class BrowseByGenreViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var selectedGenre: String?
    @Published var searchTerm: String = ""
    @Published var isLoading = false
    @Published var visibleCount = 8
    @Published var errorMessage: String?

    private let api: LibraryAPI
    private let fallbackAPI: LibraryAPI = MockLibraryAPI()

    init(api: LibraryAPI = OpenLibraryAPI()) {
        self.api = api
    }

    func fetchGenre(_ genre: String) async {
        selectedGenre = genre
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            books = try await api.searchBooks(query: genre)
            if books.isEmpty {
                books = try await fallbackAPI.searchBooks(query: genre)
            }
        } catch {
            books = (try? await fallbackAPI.searchBooks(query: genre)) ?? []
            errorMessage = "Could not load \(genre) from Open Library. Showing sample data."
        }
        normalizeGenres(with: genre)
        resetPagination()
    }

    var filtered: [Book] {
        let term = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return books.filter { book in
            let matchesSearch = term.isEmpty ||
                book.title.lowercased().contains(term) ||
                book.author.lowercased().contains(term)
            return matchesSearch
        }
    }

    var visibleBooks: [Book] {
        Array(filtered.prefix(visibleCount))
    }

    func resetPagination() {
        visibleCount = min(8, filtered.count)
    }

    func loadMore() {
        visibleCount = min(visibleCount + 8, filtered.count)
    }

    private func normalizeGenres(with fallback: String) {
        books = books.map { book in
            let trimmedGenre = book.genre.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedGenre.isEmpty || trimmedGenre == "General" else { return book }
            return Book(
                id: book.id,
                title: book.title,
                author: book.author,
                genre: fallback,
                isbn: book.isbn,
                isBorrowed: book.isBorrowed
            )
        }
    }
}

struct BrowseByGenreView: View {
    // This view is no longer used; combined into SearchView.
    @ObservedObject var reservationVM: ReservationViewModel

    var body: some View {
        SearchView(reservationVM: reservationVM)
    }
}

#Preview {
    BrowseByGenreView(reservationVM: ReservationViewModel())
        .modelContainer(DataService.container)
}

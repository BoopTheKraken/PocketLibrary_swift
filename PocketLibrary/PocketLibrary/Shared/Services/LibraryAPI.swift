//
//  LibraryApi.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import Foundation
import CoreLocation

enum LibraryAPIError: Error { case network, decoding, unknown }

// MARK: - API Protocol

protocol LibraryAPI {
    func searchBooks(query: String) async throws -> [Book]
    func nearbyBranches(
        for book: Book,
        from location: CLLocationCoordinate2D,
        radiusKM: Double
    ) async throws -> [Branch]
    func createReservation(book: Book, branchId: UUID) async throws -> Reservation
    func fetchReviews(bookId: UUID) async throws -> [Review]
    func addReview(_ review: Review) async throws
}

// MARK: - Mock API Implementation

final class MockLibraryAPI: LibraryAPI {

    static var sampleBooks: [Book] = [
        Book(title: "The Swift Programming Language", author: "Apple Inc.", genre: "Programming", isbn: "001001", isBorrowed: false),
        Book(title: "SwiftUI Essentials", author: "John Appleseed", genre: "Programming", isbn: "001002", isBorrowed: false),
        Book(title: "Advanced iOS Development", author: "Chris Lattner", genre: "Programming", isbn: "001003", isBorrowed: false),
        Book(title: "The Pragmatic Programmer", author: "Hunt & Thomas", genre: "Programming", isbn: "001004", isBorrowed: true),
        Book(title: "Clean Code", author: "Robert C. Martin", genre: "Programming", isbn: "001005", isBorrowed: false),
        Book(title: "Design Patterns", author: "Gamma et al.", genre: "Software Eng.", isbn: "001006", isBorrowed: false),
        Book(title: "The Art of Computer Programming", author: "Donald Knuth", genre: "Computer Sci.", isbn: "001007", isBorrowed: true),
        Book(title: "Introduction to Algorithms", author: "Cormen et al.", genre: "Computer Sci.", isbn: "001008", isBorrowed: false),
        Book(title: "Deep Learning", author: "Goodfellow & Bengio", genre: "AI", isbn: "001009", isBorrowed: false),
        Book(title: "Artificial Intelligence: A Modern Approach", author: "Russell & Norvig", genre: "AI", isbn: "001010", isBorrowed: true),
        Book(title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", isbn: "001011", isBorrowed: false),
        Book(title: "Harry Potter and the Sorcerer's Stone", author: "J.K. Rowling", genre: "Fantasy", isbn: "001012", isBorrowed: false),
        Book(title: "The Martian", author: "Andy Weir", genre: "Science fiction", isbn: "001013", isBorrowed: false),
        Book(title: "Dune", author: "Frank Herbert", genre: "Science fiction", isbn: "001014", isBorrowed: true),
        Book(title: "Gone Girl", author: "Gillian Flynn", genre: "Mystery", isbn: "001015", isBorrowed: false),
        Book(title: "The Da Vinci Code", author: "Dan Brown", genre: "Thriller", isbn: "001016", isBorrowed: false),
        Book(title: "Pride and Prejudice", author: "Jane Austen", genre: "Romance", isbn: "001017", isBorrowed: false),
        Book(title: "Sapiens", author: "Yuval Noah Harari", genre: "History", isbn: "001018", isBorrowed: false),
        Book(title: "Educated", author: "Tara Westover", genre: "Nonfiction", isbn: "001019", isBorrowed: false),
        Book(title: "The Silent Patient", author: "Alex Michaelides", genre: "Mystery", isbn: "001020", isBorrowed: false)
    ]

    static var sampleBranches: [Branch] = [
        Branch(
            name: "Fullerton Public Library",
            coordinate: CLLocationCoordinate2D(latitude: 33.8703, longitude: -117.9243),
            hours: "9 AM – 6 PM",
            availableCopies: 4,
            address: "353 W Commonwealth Ave, Fullerton, CA"
        ),
        Branch(
            name: "Anaheim Central Library",
            coordinate: CLLocationCoordinate2D(latitude: 33.8366, longitude: -117.9143),
            hours: "10 AM – 7 PM",
            availableCopies: 2,
            address: "500 W Broadway, Anaheim, CA"
        ),
        Branch(
            name: "Placentia Library District",
            coordinate: CLLocationCoordinate2D(latitude: 33.8722, longitude: -117.8703),
            hours: "9 AM – 5 PM",
            availableCopies: 3,
            address: "411 E Chapman Ave, Placentia, CA"
        )
    ]

    private static var sampleReviews: [Review] = [
        Review(bookId: sampleBooks[0].id, userName: "Alex", rating: 5, comment: "Great intro to Swift."),
        Review(bookId: sampleBooks[3].id, userName: "Jamie", rating: 4, comment: "Timeless advice for engineers.")
    ]

    private static var sampleReservations: [Reservation] = []

    func searchBooks(query: String) async throws -> [Book] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let q = trimmed.lowercased()
        guard !q.isEmpty else { return Self.sampleBooks }

        return Self.sampleBooks.filter {
            $0.title.lowercased().contains(q) ||
            $0.author.lowercased().contains(q) ||
            $0.genre.lowercased().contains(q) ||
            $0.isbn.lowercased().contains(q)
        }
    }

    func nearbyBranches(
        for book: Book,
        from location: CLLocationCoordinate2D,
        radiusKM: Double
    ) async throws -> [Branch] {
        let withDistances = Self.sampleBranches.map { branch in
            let distance = distance(from: location, to: branch.coordinate)
            return Branch(
                id: branch.id,
                name: branch.name,
                coordinate: branch.coordinate,
                hours: branch.hours,
                availableCopies: branch.availableCopies,
                address: branch.address,
                distance: distance
            )
        }

        return withDistances.filter { branch in
            guard let dist = branch.distance else { return true }
            return dist <= radiusKM
        }
    }

    func createReservation(book: Book, branchId: UUID) async throws -> Reservation {
        let reservation = Reservation(
            book: book,
            branchId: branchId,
            queuePosition: Int.random(in: 1...5),
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()
        )

        Self.sampleReservations.append(reservation)
        return reservation
    }

    func fetchReviews(bookId: UUID) async throws -> [Review] {
        Self.sampleReviews.filter { $0.bookId == bookId }
    }

    func addReview(_ review: Review) async throws {
        Self.sampleReviews.insert(review, at: 0)
    }

    // MARK: - Helpers

    private func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return loc1.distance(from: loc2) / 1000.0
    }
}

// MARK: - OpenLibrary API Implementation

/// Real HTTP-backed implementation of `LibraryAPI` using Open Library's search API.
/// See: https://openlibrary.org/developers/api
final class OpenLibraryAPI: LibraryAPI {

    private struct OpenLibrarySearchResponse: Decodable {
        let docs: [Doc]

        struct Doc: Decodable {
            let title: String?
            let author_name: [String]?
            let subject: [String]?
            let isbn: [String]?
            let cover_i: Int?  // Cover image ID
        }
    }

    /// Fallback branch provider for `nearbyBranches` until a real backend exists.
    private let branchProvider = MockLibraryAPI()
    private var reviews: [Review] = []

    func searchBooks(query: String) async throws -> [Book] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        // Encode query for URL
        guard let encodedQuery = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://openlibrary.org/search.json?q=\(encodedQuery)&limit=20")
        else {
            return []
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            // If API call fails, fall back to mock search to keep the app usable.
            return try await branchProvider.searchBooks(query: query)
        }

        let decoded = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)

        // Map Open Library docs into our local `Book` model.
        let books: [Book] = decoded.docs.compactMap { doc in
            guard let title = doc.title else { return nil }

            let author = doc.author_name?.first ?? "Unknown Author"
            let genre = doc.subject?
                .first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ?? "General"
            let isbn = doc.isbn?.first ?? ""

            // OpenLibrary cover image URL format: https://covers.openlibrary.org/b/id/{cover_i}-M.jpg
            let coverImageURL: String? = doc.cover_i.map {
                "https://covers.openlibrary.org/b/id/\($0)-M.jpg"
            }

            return Book(
                title: title,
                author: author,
                genre: genre,
                isbn: isbn,
                isBorrowed: false,
                coverImageURL: coverImageURL
            )
        }

        // If nothing was returned, optionally fall back to the mock implementation.
        if books.isEmpty {
            return try await branchProvider.searchBooks(query: query)
        }

        return books
    }

    func nearbyBranches(
        for book: Book,
        from location: CLLocationCoordinate2D,
        radiusKM: Double
    ) async throws -> [Branch] {
        // Open Library does not provide physical branch data; delegate to the mock implementation for now.
        try await branchProvider.nearbyBranches(for: book, from: location, radiusKM: radiusKM)
    }

    func createReservation(book: Book, branchId: UUID) async throws -> Reservation {
        // Open Library has no reservation concept; create a reservation with the provided book.
        return Reservation(
            book: book,
            branchId: branchId,
            queuePosition: Int.random(in: 1...5),
            createdAt: Date()
        )
    }

    func fetchReviews(bookId: UUID) async throws -> [Review] {
        reviews.filter { $0.bookId == bookId }
    }

    func addReview(_ review: Review) async throws {
        reviews.insert(review, at: 0)
    }
}

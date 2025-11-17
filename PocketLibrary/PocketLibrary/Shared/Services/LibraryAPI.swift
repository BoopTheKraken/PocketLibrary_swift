//
//  LibraryApi.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

// api protocol and mockapi i guess with 10 books

import Foundation
import CoreLocation

enum LibraryAPIError: Error { case network, decoding, unknown }

protocol LibraryAPI {
    func searchBooks(query: String) async throws -> [Book]
    func nearbyBranches(for book: Book, from location: CLLocationCoordinate2D, radiusKM: Double) async throws -> [Branch]
    func createReservation(bookId: UUID, branchId: UUID) async throws -> Reservation
    func fetchReviews(bookId: UUID) async throws -> [Review]
    func addReview(_ review: Review) async throws
}

final class MockLibraryAPI: LibraryAPI {
    func searchBooks(query: String) async throws -> [Book] { [] }
    func nearbyBranches(for book: Book, from location: CLLocationCoordinate2D, radiusKM: Double) async throws -> [Branch] { [] }
    func createReservation(bookId: UUID, branchId: UUID) async throws -> Reservation { .init(id: .init(), book: .init(id:.init(), title:"", author:"", genre:"", isbn:"", isBorrowed:false), branchId: .init(), queuePosition: 1, createdAt: .init()) }
    func fetchReviews(bookId: UUID) async throws -> [Review] { [] }
    func addReview(_ review: Review) async throws {}
}

//
//  ReservationViewModel.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//
import Foundation

@MainActor
final class ReservationViewModel: ObservableObject {
    @Published var reservations: [Reservation] = []

    private let api: LibraryAPI
    init(api: LibraryAPI = MockLibraryAPI()) { self.api = api }

    func reserve(book: Book, at branchId: UUID) async {
        if let r = try? await api.createReservation(bookId: book.id, branchId: branchId) {
            reservations.append(r)
        }
    }
}

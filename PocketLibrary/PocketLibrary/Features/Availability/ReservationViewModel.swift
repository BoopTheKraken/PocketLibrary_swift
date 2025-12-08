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

    init(api: LibraryAPI = OpenLibraryAPI()) {
        self.api = api
    }

    func reserve(book: Book, at branchId: UUID) async {
        do {
            let reservation = try await api.createReservation(book: book, branchId: branchId)
            reservations.append(reservation)
            ToastManager.shared.success("'\(book.title)' reserved successfully!")
            HapticFeedback.success.trigger()
        } catch {
            ToastManager.shared.error("Failed to reserve book. Please try again.")
            HapticFeedback.error.trigger()
        }
    }

    func cancel(_ reservation: Reservation) {
        reservations.removeAll { $0.id == reservation.id }
        ToastManager.shared.info("Reservation cancelled")
    }

    func seedMockReservationsIfEmpty() {
        guard reservations.isEmpty else { return }
        let books = MockLibraryAPI.sampleBooks.prefix(2)
        let branchId = MockLibraryAPI.sampleBranches.first?.id ?? UUID()

        books.forEach { book in
            let reservation = Reservation(
                book: book,
                branchId: branchId,
                queuePosition: Int.random(in: 1...3),
                createdAt: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...5), to: Date()) ?? Date()
            )
            reservations.append(reservation)
        }
    }
}

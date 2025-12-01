//
//  PaymentViewModel.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

@MainActor
final class PaymentsViewModel: ObservableObject {
    @Published var fines: [FineRecord] = []

    private let store = FineHistoryStore()

    init() {
        fines = store.load()
    }

    func addFine(title: String, amount: Double) {
        let fine = FineRecord(
            id: UUID(),
            bookTitle: title,
            amount: amount,
            date: Date()
        )
        fines.append(fine)
        store.save(fines)
    }

    func payAll() {
        // In a later version, integrate Apple Pay here.
        // For now, we simply clear fines to simulate payment.
        fines.removeAll()
        store.save(fines)
    }

    var totalAmount: Double {
        fines.reduce(0) { $0 + $1.amount }
    }

    var hasFines: Bool {
        !fines.isEmpty
    }
}

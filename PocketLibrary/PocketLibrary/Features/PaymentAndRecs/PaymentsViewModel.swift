//
//  PaymentViewModel.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI
import Combine

@MainActor
final class PaymentsViewModel: ObservableObject {
    @Published var fines: [FineRecord] = []
    private let store = FineHistoryStore()

    init() {
        fines = store.load()
    }

    func addFine(title: String, amount: Double) {
        let newFine = FineRecord(
            id: UUID(),
            bookTitle: title,
            amount: amount,
            date: Date()
        )
        fines.append(newFine)
        store.save(fines)
    }

    func payAll() {
        fines.removeAll()
        store.save(fines)
    }
}

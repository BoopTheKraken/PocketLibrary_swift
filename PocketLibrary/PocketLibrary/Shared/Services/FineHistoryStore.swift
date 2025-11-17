//
//  FineHistoryStore.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

// user defaults persistence

import Foundation
// Persistence (Core Data & UserDefaults bridge) – let's keep simple starter
final class FineHistoryStore {
    private let key = "FineHistory"
    func save(_ fines: [FineRecord]) {
        if let encoded = try? JSONEncoder().encode(fines) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    func load() -> [FineRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([FineRecord].self, from: data) else { return [] }
        return decoded
    }
}

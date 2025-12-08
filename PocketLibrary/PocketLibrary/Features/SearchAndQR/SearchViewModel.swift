//
//  SearchViewModel.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import Foundation
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {

    @Published var query: String = ""
    @Published var isSearching: Bool = false
    @Published var results: [Book] = []
    @Published var errorMessage: String?

    private let api: LibraryAPI

    init(api: LibraryAPI = OpenLibraryAPI()) {
        self.api = api
    }

    // MARK: - Search

    func performSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !isSearching else { return }
        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        do {
            let books = try await api.searchBooks(query: trimmed)
            results = books
        } catch {
            errorMessage = "Could not complete search. Please try again."
            results = []
            print("Search error: \(error)")
        }
    }

    // MARK: - Utility

    func clear() {
        query = ""
        results = []
        errorMessage = nil
    }
}

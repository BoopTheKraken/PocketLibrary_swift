//
//  AvailabilityViewModel.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI
import CoreLocation

@MainActor
final class AvailabilityViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Book] = []
    @Published var selectedBook: Book?
    @Published var branches: [Branch] = []
    @Published var isLoading = false

    private let api: LibraryAPI
    private let location: CLLocationCoordinate2D

    init(api: LibraryAPI = MockLibraryAPI(),
         location: CLLocationCoordinate2D = .init(latitude: 33.882, longitude: -117.885)) {
        self.api = api
        self.location = location
    }

    func search() async {
        guard !query.isEmpty else { results = []; return }
        isLoading = true
        defer { isLoading = false }
        results = (try? await api.searchBooks(query: query)) ?? []
    }

    func loadBranches(for book: Book) async {
        selectedBook = book
        branches = (try? await api.nearbyBranches(for: book, from: location, radiusKM: 25)) ?? []
    }
}


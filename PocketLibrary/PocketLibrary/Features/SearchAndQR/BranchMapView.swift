//
//  BranchMapView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.

import SwiftUI
import MapKit
import CoreLocation

struct BranchMapView: View {
    @StateObject private var branchManager = BranchDataManager.shared

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.8703, longitude: -117.9243),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @State private var isSearching = false
    @State private var errorMessage: String?

    private let locationService: LibraryLocationService = MapKitLibraryLocationService()

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.standard) {
                Map(initialPosition: .region(region)) {
                    ForEach(branchManager.discoveredBranches) { branch in
                        Marker(branch.name, coordinate: branch.coordinate)
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task { await searchLibrariesNearby() }
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text(isSearching ? "Searching…" : "Search Libraries Nearby")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isSearching)

                if branchManager.discoveredBranches.isEmpty {
                    VStack(spacing: 8) {
                        Text("No libraries found yet")
                            .font(.headline)
                            .foregroundStyle(Color.fg)
                        Text("Tap \"Search Libraries Nearby\" to look for libraries around the map center.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryFg)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.large)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.large)
                } else {
                    List(branchManager.discoveredBranches) { branch in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(branch.name)
                                .font(.headline)
                            if let address = branch.address {
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let distance = branch.distance {
                                Text(String(format: "%.1f km away", distance))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .padding(Spacing.large)
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle("Library Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func searchLibrariesNearby() async {
        guard !isSearching else { return }
        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        do {
            let branches = try await locationService.searchLibraries(
                near: region.center,
                radiusInMeters: 5_000
            )
            branchManager.updateBranches(branches)
        } catch {
            errorMessage = "Could not load nearby libraries. Please try again."
            print("Failed to search libraries: \(error)")
        }
    }
}

// MARK: - Location Service Protocol & Implementation

protocol LibraryLocationService {
    func searchLibraries(
        near coordinate: CLLocationCoordinate2D,
        radiusInMeters: CLLocationDistance
    ) async throws -> [Branch]
}

final class MapKitLibraryLocationService: LibraryLocationService {
    func searchLibraries(
        near coordinate: CLLocationCoordinate2D,
        radiusInMeters: CLLocationDistance = 5_000
    ) async throws -> [Branch] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "library"
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return response.mapItems.compactMap { item in
            guard let location = item.placemark.location else { return nil }

            let address = [
                item.placemark.name,
                item.placemark.thoroughfare,
                item.placemark.locality,
                item.placemark.administrativeArea
            ]
            .compactMap { $0 }
            .joined(separator: ", ")

            return Branch(
                name: item.name ?? "Library",
                coordinate: location.coordinate,
                address: address,
                distance: nil
            )
        }
    }
}

#Preview {
    BranchMapView()
}

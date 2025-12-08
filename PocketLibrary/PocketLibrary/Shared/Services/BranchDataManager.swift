//
//  BranchDataManager.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import Foundation
import CoreLocation
import Combine

/// Shared manager for storing and retrieving library branch data discovered via MapKit LocalSearch
@MainActor
final class BranchDataManager: ObservableObject {
    static let shared = BranchDataManager()

    @Published private(set) var discoveredBranches: [Branch] = []

    private init() {}

    /// Update branches from MapKit LocalSearch results
    func updateBranches(_ branches: [Branch]) {
        self.discoveredBranches = branches
    }

    /// Add a single branch
    func addBranch(_ branch: Branch) {
        if !discoveredBranches.contains(where: { $0.id == branch.id }) {
            discoveredBranches.append(branch)
        }
    }

    /// Get all discovered branches
    func getAllBranches() -> [Branch] {
        return discoveredBranches
    }

    /// Get branches near a location
    func getNearbyBranches(for location: CLLocationCoordinate2D, radiusKM: Double) -> [Branch] {
        return discoveredBranches.filter { branch in
            let distance = calculateDistance(from: location, to: branch.coordinate)
            return distance <= radiusKM
        }
    }

    /// Calculate distance between two coordinates in kilometers
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * asin(sqrt(a))
        let earthRadiusKm = 6371.0

        return earthRadiusKm * c
    }
}

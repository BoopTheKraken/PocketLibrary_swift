//
//  Models.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

// brook, branch, reservation, review, finerecord

import Foundation
import CoreLocation

struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var author: String
    var genre: String
    var isbn: String
    var isBorrowed: Bool
}

struct Coordinate: Codable, Hashable {
    var latitude: Double
    var longitude: Double
    
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

struct Branch: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var coordinate: Coordinate
    var hours: String
    var availableCopies: Int
}

struct Reservation: Identifiable, Codable, Hashable {
    let id: UUID
    var book: Book
    var branchId: UUID
    var queuePosition: Int
    var createdAt: Date
}

struct Review: Identifiable, Codable, Hashable {
    let id: UUID
    var bookId: UUID
    var userName: String
    var rating: Int
    var comment: String
    var createdAt: Date
}

struct FineRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var bookTitle: String
    var amount: Double
    var date: Date
}


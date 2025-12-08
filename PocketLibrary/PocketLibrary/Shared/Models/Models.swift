//
//  Models.swift
//  PocketLibrary
//
//  Central model definitions shared across features.
//

import Foundation
import CoreLocation

struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var author: String
    var genre: String
    var isbn: String
    var isBorrowed: Bool
    var coverImageURL: String?

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        genre: String,
        isbn: String,
        isBorrowed: Bool,
        coverImageURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.genre = genre
        self.isbn = isbn
        self.isBorrowed = isBorrowed
        self.coverImageURL = coverImageURL
    }
}

struct Branch: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var coordinate: CLLocationCoordinate2D
    var hours: String
    var availableCopies: Int
    var address: String?
    var distance: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case hours
        case availableCopies
        case address
        case distance
    }

    init(
        id: UUID = UUID(),
        name: String,
        coordinate: CLLocationCoordinate2D,
        hours: String = "9 AM – 6 PM",
        availableCopies: Int = 0,
        address: String? = nil,
        distance: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.hours = hours
        self.availableCopies = availableCopies
        self.address = address
        self.distance = distance
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let name = try container.decode(String.self, forKey: .name)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        let hours = try container.decodeIfPresent(String.self, forKey: .hours) ?? "9 AM – 6 PM"
        let availableCopies = try container.decodeIfPresent(Int.self, forKey: .availableCopies) ?? 0
        let address = try container.decodeIfPresent(String.self, forKey: .address)
        let distance = try container.decodeIfPresent(Double.self, forKey: .distance)

        self.init(
            id: id,
            name: name,
            coordinate: .init(latitude: latitude, longitude: longitude),
            hours: hours,
            availableCopies: availableCopies,
            address: address,
            distance: distance
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(hours, forKey: .hours)
        try container.encode(availableCopies, forKey: .availableCopies)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(distance, forKey: .distance)
    }

    static func == (lhs: Branch, rhs: Branch) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Reservation: Identifiable, Codable, Hashable {
    let id: UUID
    var book: Book
    var branchId: UUID
    var queuePosition: Int
    var createdAt: Date
    var expiresAt: Date

    init(
        id: UUID = UUID(),
        book: Book,
        branchId: UUID,
        queuePosition: Int = 1,
        createdAt: Date = Date(),
        expiresAt: Date = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()
    ) {
        self.id = id
        self.book = book
        self.branchId = branchId
        self.queuePosition = queuePosition
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }
}

struct Review: Identifiable, Codable, Hashable {
    let id: UUID
    var bookId: UUID
    var userName: String
    var rating: Int
    var comment: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        bookId: UUID,
        userName: String,
        rating: Int,
        comment: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.bookId = bookId
        self.userName = userName
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
    }
}

struct FineRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var bookTitle: String
    var amount: Double
    var date: Date

    init(id: UUID = UUID(), bookTitle: String, amount: Double, date: Date = Date()) {
        self.id = id
        self.bookTitle = bookTitle
        self.amount = amount
        self.date = date
    }
}

//
//  FineRecords.swift
//  PocketLibrary
//
//  Created by csuftitan on 11/14/25.
//

import Foundation

struct FineRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var bookTitle: String
    var amount: Double
    var date: Date
}

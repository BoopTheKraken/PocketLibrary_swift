//
//  ReservationView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

struct ReservationView: View {
    @StateObject private var vm = ReservationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if(vm.reservations.isEmpty) {
                    Text("No Reserved Books!").foregroundStyle(.secondary).padding()
                } else {
                    List(vm.reservations) {reservation in ReservationRow(reservation: reservation)}
                }
                Button("Reserve Book") {
                    Task{
                        let book = Book(id: UUID(), title: "Hunger Games", author: "Suzzane Collins", genre: "Fiction", isbn: "2312313", isBorrowed: true)
                        await vm.reserve(book: book, at: UUID())
                    }
                }.buttonStyle(.borderedProminent)
                
                
            }
            .navigationTitle("My Reservations")
        }
    }
}

private struct ReservationRow: View {
    let reservation: Reservation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Title: \(reservation.book.title)").font(.headline)
            Text("Author: \(reservation.book.author)").font(.subheadline).foregroundStyle(.secondary)
            HStack {
                Text("Queue: \(reservation.queuePosition)")
            }
        }
        .padding(.vertical, 4)
    }
    
}
#Preview {
    ReservationView()
        .modelContainer(DataService.container)
}

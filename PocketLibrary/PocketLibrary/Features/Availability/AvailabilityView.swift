//
//  AvailabilityView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

   struct AvailabilityView: View {
       @StateObject private var vm = AvailabilityViewModel()

       var body: some View {
           NavigationStack {
               VStack {
                   Spacer(minLength: 10)
                   TextField("Search by title, author, ISBN", text: $vm.query)
                       .textFieldStyle(.roundedBorder)
                       .padding(.horizontal)
                   Button("Search") { Task { await vm.search() } }
                       .buttonStyle(.borderedProminent)

                   List(vm.results, id: \.id) { book in
                       Button (action: {
                           Task { await vm.loadBranches(for: book) }
                       }) {
                           VStack(alignment: .leading) {
                               Text(book.title).font(.headline)
                               Text(book.author).foregroundStyle(.secondary)
                           }
                       }
                   }

                   if let book = vm.selectedBook {
                       SectionHeader("Nearby branches for \(book.title)")
                       List(vm.branches) { b in
                           HStack { Text(b.name); Spacer(); Text("\(b.availableCopies) available") }
                       }
                       .frame(maxHeight: 220)
                   }
               }
               .navigationTitle("Availability")
           }
       }
   }

   private struct SectionHeader: View {
       var text: String
       init(_ t: String) { text = t }
       var body: some View { Text(text).font(.subheadline).bold().padding(.top) }
   }

#Preview {
    AvailabilityView()
        .modelContainer(DataService.container)
}

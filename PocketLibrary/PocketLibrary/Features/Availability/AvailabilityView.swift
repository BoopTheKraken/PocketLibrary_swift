//
//  AvailabilityView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

struct AvailabilityView: View {
    @StateObject private var vm = AvailabilityViewModel()
    @ObservedObject var reservationVM: ReservationViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.standard) {
                TextField("Search by title, author, ISBN", text: $vm.query)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, Spacing.standard)

                Button {
                    Task { await vm.search() }
                } label: {
                    HStack {
                        if vm.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                        Text(vm.isLoading ? "Searching…" : "Search")
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Spacing.standard)

                List(vm.results) { book in
                    Button {
                        Task { await vm.loadBranches(for: book) }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(book.title).font(.headline)
                            Text(book.author).foregroundStyle(.secondary)
                        }
                    }
                }

                if let book = vm.selectedBook {
                    SectionHeader("Nearby branches for \(book.title)")
                    List(vm.branches) { branch in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(branch.name)
                                Text("\(branch.availableCopies) available").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Reserve") {
                                Task { await reservationVM.reserve(book: book, at: branch.id) }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .frame(maxHeight: 220)
                }
            }
            .padding(.vertical, Spacing.standard)
            .navigationTitle("Availability")
            .background(Color.bg.ignoresSafeArea())
        }
    }
}

private struct SectionHeader: View {
    var text: String
    init(_ t: String) { text = t }
    var body: some View {
        Text(text)
            .font(.subheadline)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.standard)
            .padding(.horizontal, Spacing.standard)
    }
}

#Preview {
    AvailabilityView(reservationVM: ReservationViewModel())
        .modelContainer(DataService.container)
}

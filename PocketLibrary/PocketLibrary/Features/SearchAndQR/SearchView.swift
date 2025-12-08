//
//  SearchView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @StateObject private var availabilityVM = AvailabilityViewModel()
    @ObservedObject var reservationVM: ReservationViewModel
    @State private var selectedGenre: String?
    @State private var visibleCount = 12
    @State private var showBranchesForBook: Book?

    private let genres = [
        "Fantasy",
        "Science fiction",
        "Mystery",
        "Romance",
        "History",
        "Horror",
        "Thriller",
        "Young adult",
        "Nonfiction",
        "Biography",
        "Programming",
        "AI"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.standard) {
                // Search field
                HStack(spacing: Spacing.standard) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.secondaryFg)
                        .accessibilityHidden(true)

                    TextField("Search by title, author, or genre", text: $viewModel.query)
                        .textFieldStyle(.plain)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .accessibilityLabel("Search library")

                    if !viewModel.query.isEmpty {
                        Button {
                            viewModel.clear()
                            selectedGenre = nil
                            visibleCount = 12
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.secondaryFg)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear search")
                    }
                }
                .padding(Spacing.standard)
                .background(Color.secondaryBg)
                .cornerRadius(CornerRadius.medium)

                // Genre chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.small) {
                        ForEach(genres, id: \.self) { genre in
                            Button {
                                selectGenre(genre)
                            } label: {
                                Text(genre)
                                    .font(.subheadline)
                                    .padding(.horizontal, Spacing.standard)
                                    .padding(.vertical, Spacing.small)
                                    .background(
                                        selectedGenre == genre
                                        ? Color.accent
                                        : Color.secondaryBg
                                    )
                                    .foregroundStyle(
                                        selectedGenre == genre
                                        ? Color.white
                                        : Color.fg
                                    )
                                    .cornerRadius(CornerRadius.large)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Spacing.standard)
                }

                // Search button
                Button {
                    visibleCount = 12
                    Task { await viewModel.performSearch() }
                } label: {
                    HStack {
                        if viewModel.isSearching {
                            ProgressView()
                                .tint(.white)
                                .accessibilityHidden(true)
                        } else {
                            Image(systemName: "text.book.closed")
                                .accessibilityHidden(true)
                        }
                        Text(viewModel.isSearching ? "Searching…" : "Search Library")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isSearching)
                .accessibilityLabel(viewModel.isSearching ? "Searching library" : "Search library")

                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Results list
                if viewModel.results.isEmpty && !viewModel.isSearching && viewModel.query.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Find your next read")
                            .font(.headline)
                            .foregroundStyle(Color.fg)
                        Text("Search by title, author, or genre to discover books available in your pocket library.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryFg)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.large)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else if viewModel.results.isEmpty && !viewModel.isSearching && !viewModel.query.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("No results")
                            .font(.headline)
                            .foregroundStyle(Color.fg)
                        Text("Try a different title, author name, or genre.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryFg)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    List(visibleResults) { book in
                        HStack(spacing: Spacing.standard) {
                            // Book Cover
                            BookCoverImage(
                                coverURL: book.coverImageURL,
                                width: 60,
                                height: 90
                            )

                            // Book Details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                HStack {
                                    Text(book.genre)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    if !book.isbn.isEmpty {
                                        Text("•")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("ISBN: \(book.isbn.prefix(10))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }

                                Button {
                                    showBranchesFor(book)
                                } label: {
                                    Label("View availability", systemImage: "location.viewfinder")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)

                    if visibleCount < viewModel.results.count {
                        Button {
                            loadMore()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Load more")
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(Spacing.large)
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.performSearch() }
            .sheet(item: $showBranchesForBook) { book in
                BranchesSheet(book: book, availabilityVM: availabilityVM, reservationVM: reservationVM)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private func showBranchesFor(_ book: Book) {
        showBranchesForBook = book
        Task { await availabilityVM.loadBranches(for: book) }
    }

    private var visibleResults: [Book] {
        Array(viewModel.results.prefix(visibleCount))
    }

    private func loadMore() {
        visibleCount = min(visibleCount + 10, viewModel.results.count)
    }

    private func selectGenre(_ genre: String) {
        guard !viewModel.isSearching else { return }
        selectedGenre = genre
        viewModel.query = genre
        visibleCount = 12
        Task { await viewModel.performSearch() }
    }
}

struct BranchesSheet: View {
    let book: Book
    @ObservedObject var availabilityVM: AvailabilityViewModel
    @ObservedObject var reservationVM: ReservationViewModel
    @State private var isReserving = false
    @State private var reservedBranchName: String?
    @State private var showingReservationConfirmation = false
    @State private var selectedBranch: Branch?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            Text(book.title)
                .font(.headline)
            Text("Available nearby")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if availabilityVM.branches.isEmpty {
                ProgressView("Loading branches…")
                    .accessibilityLabel("Loading library branches")
            } else {
                List(availabilityVM.branches) { branch in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(branch.name)
                                    .font(.body)
                                if let address = branch.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text("\(branch.availableCopies) available")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let distance = branch.distance {
                                Text(String(format: "%.1f km", distance))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if reservedBranchName == branch.name {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.featureGreen)
                                    .accessibilityLabel("Reserved")
                                Text("Reserved!")
                                    .font(.caption)
                                    .foregroundStyle(Color.featureGreen)
                            }
                        } else {
                            Button {
                                selectedBranch = branch
                                showingReservationConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "bookmark.fill")
                                        .foregroundStyle(.white)
                                    Text("Reserve at this branch")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isReserving)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(Spacing.large)
        .confirmationDialog(
            "Reserve Book",
            isPresented: $showingReservationConfirmation,
            titleVisibility: .visible,
            presenting: selectedBranch
        ) { branch in
            Button("Reserve at \(branch.name)") {
                Task { await reserve(branch: branch) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { branch in
            Text("Reserve '\(book.title)' at \(branch.name)? You'll be notified when it's ready for pickup.")
        }
    }

    private func reserve(branch: Branch) async {
        guard !isReserving else { return }
        isReserving = true
        defer { isReserving = false }
        await reservationVM.reserve(book: book, at: branch.id)
        reservedBranchName = branch.name
        HapticFeedback.success.trigger()
    }
}

#Preview {
    SearchView(reservationVM: ReservationViewModel())
        .modelContainer(DataService.container)
}

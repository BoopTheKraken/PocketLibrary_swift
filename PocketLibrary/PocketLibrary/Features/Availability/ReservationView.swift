//
//  ReservationView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

struct ReservationView: View {
    @ObservedObject var reservationVM: ReservationViewModel

    var body: some View {
        NavigationStack {
            Group {
                if reservationVM.reservations.isEmpty {
                    VStack(spacing: Spacing.standard) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.secondaryFg)
                        Text("No reservations yet")
                            .font(.headline)
                            .foregroundStyle(Color.fg)
                        Text("Reserve a book from Search & Discover to see it here.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryFg)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.large)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(reservationVM.reservations) { reservation in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(reservation.book.title)
                                    .font(.headline)
                                Text(reservation.book.author)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(Color.featureBlue)
                                        .font(.caption)
                                    Text("Branch ID: \(reservation.branchId.uuidString.prefix(8))…")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Image(systemName: "person.2.fill")
                                        .foregroundStyle(Color.featureOrange)
                                        .font(.caption)
                                    Text("Queue: #\(reservation.queuePosition)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.top, 2)

                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .foregroundStyle(Color.featureGreen)
                                        .font(.caption2)
                                    Text("Reserved \(reservation.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }

                                HStack(spacing: 4) {
                                    Image(systemName: "hourglass")
                                        .foregroundStyle(Color.featureRed)
                                        .font(.caption2)
                                    Text("Expires \(reservation.expiresAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        reservationVM.cancel(reservation)
                                    }
                                    HapticFeedback.success.trigger()
                                } label: {
                                    Label("Cancel", systemImage: "trash.fill")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    // Share reservation details
                                    HapticFeedback.light.trigger()
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .tint(.featureBlue)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Reservations")
            .background(Color.bg.ignoresSafeArea())
        }
    }
}

#Preview {
    ReservationView(reservationVM: ReservationViewModel())
        .modelContainer(DataService.container)
}

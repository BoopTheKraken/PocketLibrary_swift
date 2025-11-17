//
//  PaymentsView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI

struct PaymentsView: View {
    @StateObject private var vm = PaymentsViewModel()

    var body: some View {
        VStack {
            if vm.fines.isEmpty {
                VStack(spacing: 12) {
                    Text("No outstanding fines 🎉")
                        .font(.headline)
                    Text("Add a demo fine to test the Payments screen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                List(vm.fines) { fine in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fine.bookTitle)
                                .font(.headline)
                            Text(fine.date.formatted())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(fine.amount, format: .currency(code: "USD"))
                            .font(.body.weight(.bold))
                    }
                }
            }

            HStack {
                Button("Add Demo Fine") {
                    vm.addFine(title: "1984", amount: 3.50)
                }

                Spacer()

                Button("Pay All (Sandbox)") {
                    vm.payAll()
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.fines.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Fines & Payments")
    }
}

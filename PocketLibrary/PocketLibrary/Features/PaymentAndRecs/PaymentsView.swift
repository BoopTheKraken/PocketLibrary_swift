//
//  PaymentsView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//
// Modified by Yuchen Chung 11/30/25

import SwiftUI

struct PaymentsView: View {
    @StateObject private var viewModel = PaymentsViewModel()

    var body: some View {
        VStack {
            if viewModel.fines.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 40))
                    Text("No outstanding fines!")
                        .font(.title3)
                        .accessible()
                }
                .padding()
            } else {
                List(viewModel.fines) { fine in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fine.bookTitle)
                                .font(.headline)
                                .accessible()

                            Text(fine.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .accessible()
                        }
                        Spacer()
                        Text(fine.amount, format: .currency(code: "USD"))
                            .bold()
                            .accessible()
                    }
                }

                HStack {
                    Text("Total: ")
                        .font(.headline)
                    Text(viewModel.totalAmount, format: .currency(code: "USD"))
                        .bold()
                    Spacer()
                    Button("Pay All (Sandbox)") {
                        viewModel.payAll()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }

            // Demo button for testing without backend
            Button("Add Demo Fine") {
                viewModel.addFine(title: "1984", amount: 3.50)
            }
            .padding(.bottom)
        }
        .navigationTitle("Fines & Payments")
        .background(Color.appBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        PaymentsView()
    }
}


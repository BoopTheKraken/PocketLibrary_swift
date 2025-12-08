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
    @State private var showingPaymentConfirmation = false

    var body: some View {
        VStack {
            if viewModel.fines.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.featureGreen)
                        .accessibilityLabel("No fines")
                    Text("No outstanding fines!")
                        .font(.title3)
                        .accessible()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                        showingPaymentConfirmation = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, Spacing.standard)
                .padding(.bottom)
            }

            // Demo button for testing without backend
            Button("Add Demo Fine") {
                viewModel.addFine(title: "1984", amount: 3.50)
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.standard)
            .padding(.bottom)
        }
        .navigationTitle("Fines & Payments")
        .background(Color.bg.ignoresSafeArea())
        .confirmationDialog(
            "Pay All Fines",
            isPresented: $showingPaymentConfirmation,
            titleVisibility: .visible
        ) {
            Button("Pay \(viewModel.totalAmount, format: .currency(code: "USD"))") {
                viewModel.payAll()
                HapticFeedback.success.trigger()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to pay all outstanding fines? This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        PaymentsView()
    }
}

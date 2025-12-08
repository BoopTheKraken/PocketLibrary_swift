//
//  QRCardView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCardView: View {
    // Simple persisted fields for the library card.
    @AppStorage("libraryCardNumber") private var cardNumber: String = "LIB-1234-5678"
    @AppStorage("libraryCardHolder") private var cardHolderName: String = "PocketLibrary Member"
    @AppStorage("libraryCardExpiry") private var cardExpiry: String = "12/2026"

    private let context = CIContext()

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.large) {
                // Card preview
                VStack(alignment: .leading, spacing: Spacing.standard) {
                    Text("PocketLibrary Card")
                        .font(.headline)
                        .foregroundStyle(Color.fg)

                    Text(cardHolderName)
                        .font(.title3.bold())
                        .foregroundStyle(Color.fg)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Card Number")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryFg)
                            Text(cardNumber)
                                .font(.subheadline.monospaced())
                                .foregroundStyle(Color.fg)
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Expires")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryFg)
                            Text(cardExpiry)
                                .font(.subheadline)
                                .foregroundStyle(Color.fg)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(Spacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondaryBg)
                .cornerRadius(CornerRadius.large)
                .shadow(color: Color.cardShadow, radius: 6, x: 0, y: 3)

                // QR code
                VStack(spacing: Spacing.standard) {
                    if let qr = generateQRCode(from: qrPayload) {
                        qr
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .background(Color.bg)
                            .cornerRadius(CornerRadius.medium)
                            .shadow(color: Color.cardShadow, radius: 4, x: 0, y: 2)
                    } else {
                        Image(systemName: "xmark.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                    }

                    Text("Show this code at the desk to check out books.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryFg)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.large)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
            }
            .padding(Spacing.large)
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle("Library Card")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Combined payload encoded in the QR (simple JSON-like string).
    private var qrPayload: String {
        """
        {
          "cardNumber": "\(cardNumber)",
          "holder": "\(cardHolderName)",
          "expiry": "\(cardExpiry)"
        }
        """
    }

    /// Generates a SwiftUI Image representing a QR code for the given string.
    private func generateQRCode(from string: String) -> Image? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        // Scale up the QR code so it looks crisp
        let transform = CGAffineTransform(scaleX: 8, y: 8)
        let scaledImage = outputImage.transformed(by: transform)

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return Image(decorative: cgImage, scale: 1.0, orientation: .up)
    }
}

#Preview {
    QRCardView()
        .modelContainer(DataService.container)
}

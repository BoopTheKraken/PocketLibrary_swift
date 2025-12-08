//
//  BookCoverImage.swift
//  PocketLibrary
//
//  Modern book cover image component with loading states
//

import SwiftUI

struct BookCoverImage: View {
    let coverURL: String?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Group {
            if let urlString = coverURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // Loading state with shimmer effect
                        ShimmerPlaceholder(width: width, height: height)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: height)
                            .clipped()
                    case .failure:
                        // Failed to load - show placeholder
                        PlaceholderCover(width: width, height: height)
                    @unknown default:
                        PlaceholderCover(width: width, height: height)
                    }
                }
            } else {
                // No URL provided - show placeholder
                PlaceholderCover(width: width, height: height)
            }
        }
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Placeholder Cover
struct PlaceholderCover: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.featureBlue.opacity(0.3),
                    Color.featurePurple.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "book.fill")
                .font(.system(size: width * 0.4))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Shimmer Loading Effect
struct ShimmerPlaceholder: View {
    let width: CGFloat
    let height: CGFloat

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.secondaryBg

            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.white.opacity(0.3),
                    Color.clear
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isAnimating ? width : -width)
        }
        .frame(width: width, height: height)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BookCoverImage(
            coverURL: "https://covers.openlibrary.org/b/id/8739161-M.jpg",
            width: 80,
            height: 120
        )

        BookCoverImage(
            coverURL: nil,
            width: 80,
            height: 120
        )
    }
    .padding()
}

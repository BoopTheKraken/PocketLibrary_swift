//
//  ToastView.swift
//  PocketLibrary
//
//  Modern toast notification system
//

import SwiftUI

// MARK: - Toast Model
struct Toast: Equatable {
    enum ToastType {
        case success
        case error
        case info
        case warning
    }

    let id = UUID()
    let message: String
    let type: ToastType
    let duration: Double

    init(message: String, type: ToastType = .info, duration: Double = 3.0) {
        self.message = message
        self.type = type
        self.duration = duration
    }

    var icon: String {
        switch type {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch type {
        case .success: return .featureGreen
        case .error: return .featureRed
        case .info: return .featureBlue
        case .warning: return .featureOrange
        }
    }

    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Manager
@MainActor
class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var toast: Toast?

    private init() {}

    func show(_ toast: Toast) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            self.toast = toast
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
            self.dismiss()
        }
    }

    func dismiss() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            toast = nil
        }
    }

    // Convenience methods
    func success(_ message: String) {
        show(Toast(message: message, type: .success))
    }

    func error(_ message: String) {
        show(Toast(message: message, type: .error))
    }

    func info(_ message: String) {
        show(Toast(message: message, type: .info))
    }

    func warning(_ message: String) {
        show(Toast(message: message, type: .warning))
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: Toast
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0

    var body: some View {
        HStack(spacing: Spacing.standard) {
            Image(systemName: toast.icon)
                .font(.title3)
                .foregroundStyle(toast.color)

            Text(toast.message)
                .font(.subheadline)
                .foregroundStyle(Color.fg)
                .lineLimit(2)

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryFg)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.standard)
        .background(
            ZStack {
                Color.secondaryBg
                    .opacity(0.95)

                // Accent bar on the left
                HStack {
                    Rectangle()
                        .fill(toast.color)
                        .frame(width: 4)

                    Spacer()
                }
            }
        )
        .cornerRadius(CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .padding(.horizontal, Spacing.large)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                offset = 0
                opacity = 1
            }
        }
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @StateObject private var toastManager = ToastManager.shared

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if let toast = toastManager.toast {
                GeometryReader { geometry in
                    VStack {
                        ToastView(toast: toast) {
                            toastManager.dismiss()
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1000)

                        Spacer()
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 8)
                }
                .ignoresSafeArea()
            }
        }
    }
}

extension View {
    func toastView() -> some View {
        modifier(ToastModifier())
    }
}

#Preview {
    VStack {
        Button("Show Success Toast") {
            ToastManager.shared.success("Book reserved successfully!")
        }
        .buttonStyle(.borderedProminent)

        Button("Show Error Toast") {
            ToastManager.shared.error("Failed to load books")
        }
        .buttonStyle(.borderedProminent)

        Button("Show Info Toast") {
            ToastManager.shared.info("3 new books available")
        }
        .buttonStyle(.borderedProminent)

        Button("Show Warning Toast") {
            ToastManager.shared.warning("Reservation expires in 2 hours")
        }
        .buttonStyle(.borderedProminent)
    }
    .toastView()
}

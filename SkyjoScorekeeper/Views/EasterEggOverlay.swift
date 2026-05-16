import SwiftUI

struct EasterEggOverlay: View {
    let onDismiss: () -> Void

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Text("🌸")
                    .font(.system(size: 52))
                    .padding(.bottom, 16)
                    .accessibilityHidden(true)

                Text("Happy Mother's Day,\nShawn!")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .tracking(-0.5)
                    .padding(.bottom, 28)

                Button("Close", action: onDismiss)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(colorSchemeContrast == .increased ? Theme.brandHighContrast : Theme.brand)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .padding(28)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(24)
            .shadow(color: .black.opacity(0.25), radius: 32, y: 24)
            .transition(.scale(scale: 0.9, anchor: .center).combined(with: .opacity))
        }
    }
}

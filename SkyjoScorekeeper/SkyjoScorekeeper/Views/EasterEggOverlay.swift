import SwiftUI

struct EasterEggOverlay: View {
    let onDismiss: () -> Void

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

                Text("Happy Mother's Day,\nShawn!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .tracking(-0.5)
                    .padding(.bottom, 28)

                Button("Close", action: onDismiss)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Theme.brand)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .padding(28)
            .background(.white.opacity(0.97))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(24)
            .shadow(color: .black.opacity(0.25), radius: 32, y: 24)
            .transition(.scale(scale: 0.9, anchor: .center).combined(with: .opacity))
        }
    }
}

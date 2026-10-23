import SwiftUI

struct EasterEggOverlay: View {
    @Binding var isPresented: Bool
    /// The page holding the title the egg came from (iPhone Duo open or propped);
    /// the card centres there, clear of the fold. nil: the whole screen.
    let page: CGRect?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        ZStack {
            if isPresented {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }
                    .transition(.opacity)
            }

            cardSlot
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: isPresented)
    }

    /// A page-sized slot for the card. The card scales in from the top of its
    /// page, where the title it came from sits.
    @ViewBuilder
    private var cardSlot: some View {
        let slot = ZStack {
            if isPresented {
                card
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale(scale: 0.9, anchor: .top).combined(with: .opacity))
            }
        }
        if let page {
            slot
                .frame(width: page.width, height: page.height)
                .position(x: page.midX, y: page.midY)
        } else {
            slot
        }
    }

    private var card: some View {
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

            Button("Close") { isPresented = false }
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
        .frame(maxWidth: Theme.contentMaxWidth)
        .padding(24)
        .shadow(color: .black.opacity(0.25), radius: 32, y: 24)
    }
}

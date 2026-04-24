import SwiftUI

struct ReviewPromptView: View {
    let onLoveIt: () -> Void
    let onNotReally: () -> Void

    private let darkText = Color(hex: "2A2A2A")
    private let ctaBlue = Color(hex: "375BCD")

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onNotReally() }

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(ctaBlue.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: "star.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(ctaBlue)
                }
                .padding(.top, 28)

                Text("ENJOYING THE DAILY CATCH?")
                    .font(AppTheme.headline(22))
                    .foregroundStyle(darkText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text("We're a small team building this by hand. A quick rating on the App Store helps more than you know.")
                    .font(AppTheme.body(14).weight(.medium))
                    .foregroundStyle(darkText.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    Button(action: onLoveIt) {
                        Text("YES, LOVE IT")
                            .font(AppTheme.mono(14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ctaBlue)
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: onNotReally) {
                        Text("Not really")
                            .font(AppTheme.body(13).weight(.medium))
                            .foregroundStyle(darkText.opacity(0.5))
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "E8E7E5"))
                    .shadow(color: Color.black.opacity(0.2), radius: 20, y: 8)
            )
            .padding(.horizontal, 32)
        }
    }
}

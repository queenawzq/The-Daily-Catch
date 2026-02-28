import SwiftUI

struct OnboardingIntroView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "E8E7E5")
                .ignoresSafeArea()

            // Background binder rings — full opacity, smaller
            Image("OnboardingBackground")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Paper clamp + tape sticker at top right
                ZStack(alignment: .topTrailing) {
                    // Tape sticker — right aligned, same size as splash
                    Image("CatchRightTape")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 110)
                        .rotationEffect(.degrees(2), anchor: .trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 34)

                    // Paper clamp on top
                    Image("PaperClamp")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .padding(.trailing, 30)
                        .offset(y: -30)
                }

                Spacer()

                // Help us icon — smaller
                Image("HelpUsIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)

                // Headline — bigger
                Text("HELP US SET UP\nYOUR CATCH.")
                    .font(AppTheme.headline(34, weight: .black))
                    .foregroundStyle(AppTheme.textDark)
                    .multilineTextAlignment(.center)

                // Subtitle — medium weight
                Text("5 stories. 2 minutes. Everyday.\nWe just need to know a little about you\nso we catch the right ones.")
                    .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    .multilineTextAlignment(.center)

                // Let's go button — smaller, #CEDCE9, no rounded corners, shadow on button only
                Button(action: onContinue) {
                    Text("LET'S GO")
                        .font(AppTheme.mono(14, weight: .bold))
                        .foregroundStyle(AppTheme.textDark)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            Color(hex: "CEDCE9")
                                .shadow(.drop(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 2))
                        )
                }

                Spacer()
                Spacer()
            }
        }
    }
}

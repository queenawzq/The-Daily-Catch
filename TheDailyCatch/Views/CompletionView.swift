import SwiftUI

struct CompletionView: View {
    var onRefresh: () -> Void

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            // Background image
            VStack {
                Spacer()
                Image("CaughtUpBackground")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.3)
            }
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Tape sticker
                Image("WellDoneCaughtUpTape")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .rotationEffect(.degrees(-2))
                    .padding(.horizontal, 32)

                // Coffee icon
                Image("CaughtUpIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)

                // Headline
                Text("YOU ARE ALL\nCAUGHT UP.")
                    .font(AppTheme.headline(28, weight: .black))
                    .foregroundStyle(AppTheme.textDark)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("That's your catch for today.\nGo live your life. See you tomorrow :)")
                    .font(AppTheme.body(14))
                    .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    .multilineTextAlignment(.center)

                // Next catch badge
                Text("Next Catch Tomorrow, 7:00 AM ET")
                    .font(AppTheme.mono(11, weight: .medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.6))
                    .clipShape(Capsule())

                Spacer()

                // Want more button
                Button(action: onRefresh) {
                    Text("WANT MORE?")
                        .font(AppTheme.mono(15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.textDark)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

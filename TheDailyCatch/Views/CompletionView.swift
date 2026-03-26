import SwiftUI

struct CompletionView: View {
    var nextRefresh: Date?
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
                Text(nextCatchText)
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

    private var nextCatchText: String {
        guard let next = nextRefresh else { return "New Catch Tomorrow" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeStr = formatter.string(from: next)
        if Calendar.current.isDateInToday(next) {
            return "New Catch Today at \(timeStr)"
        }
        return "New Catch Tomorrow at \(timeStr)"
    }
}

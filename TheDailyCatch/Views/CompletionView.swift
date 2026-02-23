import SwiftUI

struct CompletionView: View {
    var onRefresh: () -> Void
    var onRestart: () -> Void

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("🎉")
                    .font(.system(size: 72))

                Text("You're all caught up!")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Come back later for fresh stories\nor refresh now for a new brief.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onRefresh) {
                        Label("Get Fresh Stories", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(action: onRestart) {
                        Text("Read again")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

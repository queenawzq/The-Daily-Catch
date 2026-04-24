import SwiftUI

struct OnboardingNotificationsView: View {
    var onContinue: () -> Void

    @State private var isRequesting = false

    var body: some View {
        ZStack {
            Color(hex: "E8E7E5")
                .ignoresSafeArea()

            Image("OnboardingBackground")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Top spacer — matches the tape+clamp block area on the "You're all set" page
                Spacer().frame(height: 180)

                Spacer()

                // Bell icon
                Image("NotificationBellIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)

                // Headline
                Text("DON'T MISS YOUR\nDAILY CATCH.")
                    .font(AppTheme.headline(34, weight: .black))
                    .foregroundStyle(AppTheme.textDark)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("A gentle daily nudge when your brief is ready.\nYou pick the time — we never spam.")
                    .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    .multilineTextAlignment(.center)

                // Enable daily reminder button (matches "LET'S GO" styling)
                Button {
                    guard !isRequesting else { return }
                    isRequesting = true
                    Task {
                        let granted = await NotificationService.shared.requestAuthorization()
                        let prefs = UserPreferencesService.shared
                        await MainActor.run {
                            if granted {
                                prefs.notificationsEnabled = true
                                NotificationService.shared.scheduleDailyReminder(
                                    hour: prefs.notificationHour,
                                    minute: prefs.notificationMinute
                                )
                                if prefs.reengagementNotificationsEnabled {
                                    NotificationService.shared.scheduleReengagementReminder()
                                }
                            }
                            isRequesting = false
                            onContinue()
                        }
                    }
                } label: {
                    Text("ENABLE DAILY REMINDER")
                        .font(AppTheme.mono(14, weight: .bold))
                        .foregroundStyle(AppTheme.textDark)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Color(hex: "CEDCE9")
                                .shadow(.drop(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 2))
                        )
                }
                .buttonStyle(.plain)
                .disabled(isRequesting)

                Button(action: onContinue) {
                    Text("Not now")
                        .font(AppTheme.body(13).weight(.medium))
                        .foregroundStyle(AppTheme.textDark.opacity(0.5))
                        .underline()
                }
                .buttonStyle(.plain)

                Spacer()
                Spacer()
            }
        }
    }
}

import SwiftUI

struct OnboardingNotificationsView: View {
    var onContinue: () -> Void

    @State private var isRequesting = false

    private let ctaBlue = Color(hex: "375BCD")

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
                Spacer()

                ZStack {
                    Circle()
                        .fill(ctaBlue.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(ctaBlue)
                }

                Text("DON'T MISS YOUR\nDAILY CATCH.")
                    .font(AppTheme.headline(32, weight: .black))
                    .foregroundStyle(AppTheme.textDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("A gentle daily nudge when your brief is ready. You pick the time — we never spam.")
                    .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .lineSpacing(3)

                Spacer()

                VStack(spacing: 12) {
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
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ctaBlue)
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
                    .padding(.top, 4)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

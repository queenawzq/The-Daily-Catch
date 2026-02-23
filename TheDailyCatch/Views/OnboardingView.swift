import SwiftUI

struct OnboardingView: View {
    @State private var selectedModes: Set<IdentityMode> = []
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text("the daily catch")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Who are you today?")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Pick your vibe. We'll curate your news.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(IdentityMode.allCases) { mode in
                        IdentityCard(
                            mode: mode,
                            isSelected: selectedModes.contains(mode)
                        ) {
                            if selectedModes.contains(mode) {
                                selectedModes.remove(mode)
                            } else {
                                selectedModes.insert(mode)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    let prefs = UserPreferencesService.shared
                    prefs.selectedIdentityModes = Array(selectedModes)
                    prefs.isOnboardingComplete = true
                    onComplete()
                } label: {
                    Text("Let's go")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedModes.isEmpty)
                .opacity(selectedModes.isEmpty ? 0.5 : 1)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

struct IdentityCard: View {
    let mode: IdentityMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mode.emoji)
                    .font(.system(size: 36))
                Text(mode.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppTheme.accent.opacity(0.3) : AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.accent : Color.clear, lineWidth: 2)
            )
        }
    }
}

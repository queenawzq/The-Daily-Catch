import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 1
    @State private var selectedLifeStage: LifeStage?
    @State private var selectedTopics: Set<TopicInterest> = []
    @State private var selectedMotivation: ReadingMotivation?

    var onComplete: () -> Void

    private let subtitles: [Int: String] = [
        1: "The help us pick stories that actually matter to your life.",
        2: "Select all that interest you. We'll use these to curate your catch.",
        3: "This helps us set the right tone for your stories."
    ]

    var body: some View {
        Group {
            switch currentStep {
            case 1:
                lifeStageStep
            case 2:
                topicsStep
            case 3:
                motivationStep
            default:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }

    // MARK: - Step 1: Life Stage

    private var lifeStageStep: some View {
        ZStack {
            Color(hex: "E8E7E5").ignoresSafeArea()

            VStack(spacing: 0) {
                stepHeader(step: 1, title: "WHERE ARE YOU RIGHT NOW?", dark: false)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(LifeStage.allCases) { stage in
                            onboardingRow(
                                emoji: stage.emoji,
                                label: stage.displayName.uppercased(),
                                isSelected: selectedLifeStage == stage,
                                dark: false
                            ) {
                                selectedLifeStage = stage
                            }
                        }
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 28)
                    .padding(.top, 16)
                    .padding(.bottom, 6)
                }

                continueButton(
                    enabled: selectedLifeStage != nil,
                    label: "CONTINUE"
                ) {
                    currentStep = 2
                }
            }
        }
    }

    // MARK: - Step 2: Topics

    private var topicsStep: some View {
        ZStack {
            Color(hex: "E8E7E5").ignoresSafeArea()

            VStack(spacing: 0) {
                stepHeader(step: 2, title: "WHAT DO YOU ACTUALLY\nCARE ABOUT?", dark: false)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(TopicInterest.allCases) { topic in
                            topicRow(topic: topic)
                        }
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 28)
                    .padding(.top, 16)
                    .padding(.bottom, 6)
                }
                .scrollIndicators(.visible)

                continueButton(
                    enabled: !selectedTopics.isEmpty,
                    label: "CONTINUE (\(selectedTopics.count) SELECTED)"
                ) {
                    currentStep = 3
                }
            }
        }
    }

    // MARK: - Step 3: Motivation

    private var motivationStep: some View {
        ZStack {
            Color(hex: "E8E7E5").ignoresSafeArea()

            VStack(spacing: 0) {
                stepHeader(step: 3, title: "WHY DO YOU WANT TO\nSTAY INFORMED?", dark: false)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(ReadingMotivation.allCases) { motivation in
                            onboardingRow(
                                emoji: motivation.emoji,
                                label: motivation.displayName.uppercased(),
                                isSelected: selectedMotivation == motivation,
                                dark: false
                            ) {
                                selectedMotivation = motivation
                            }
                        }
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 28)
                    .padding(.top, 16)
                    .padding(.bottom, 6)
                }

                continueButton(
                    enabled: selectedMotivation != nil,
                    label: "FINISH"
                ) {
                    savePreferences()
                    onComplete()
                }
            }
        }
    }

    // MARK: - Components

    private func stepHeader(step: Int, title: String, dark: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if step > 1 {
                    Button {
                        currentStep = step - 1
                    } label: {
                        Text("< BACK")
                            .font(AppTheme.mono(14, weight: .bold))
                            .foregroundStyle(AppTheme.textDark)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Text("\(step)/3")
                .font(AppTheme.mono(13))
                .foregroundStyle(Color(hex: "5D84C4"))
                .padding(.horizontal, 24)
                .padding(.top, 8)

            Text(title)
                .font(AppTheme.headline(28, weight: .black))
                .foregroundStyle(AppTheme.textDark)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

            if let subtitle = subtitles[step] {
                Text(subtitle)
                    .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 4)
            }
        }
    }

    private func onboardingRow(emoji: String, label: String, isSelected: Bool, dark: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.title2)
                Text(label)
                    .font(AppTheme.mono(13, weight: .bold))
                    .foregroundStyle(AppTheme.textDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(AppTheme.textDark)
                        .font(.body.weight(.bold))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color(hex: "CEDCE9") : Color(hex: "F2F2F2"))
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: Color.black.opacity(0.25), radius: 2, x: 2, y: 2)
        }
    }

    private func topicRow(topic: TopicInterest) -> some View {
        let isSelected = selectedTopics.contains(topic)
        return Button {
            if isSelected {
                selectedTopics.remove(topic)
            } else {
                selectedTopics.insert(topic)
            }
        } label: {
            HStack(spacing: 14) {
                Text(topic.emoji)
                    .font(.title2)
                Text(topic.displayName.uppercased())
                    .font(AppTheme.mono(13, weight: .bold))
                    .foregroundStyle(AppTheme.textDark)
                Spacer()
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? AppTheme.textDark : AppTheme.textMidGrey)
                    .font(.title3)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color(hex: "CEDCE9") : Color(hex: "F2F2F2"))
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: Color.black.opacity(0.25), radius: 2, x: 2, y: 2)
        }
    }

    private func continueButton(enabled: Bool, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppTheme.mono(14, weight: .bold))
                .foregroundStyle(AppTheme.textDark)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(
                    Color(hex: "CEDCE9")
                        .opacity(enabled ? 1 : 0.5)
                        .shadow(.drop(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 2))
                )
        }
        .disabled(!enabled)
        .padding(.vertical, 20)
    }

    private func savePreferences() {
        let prefs = UserPreferencesService.shared
        prefs.selectedLifeStage = selectedLifeStage
        prefs.selectedTopics = Array(selectedTopics)
        prefs.selectedMotivation = selectedMotivation
        prefs.isOnboardingComplete = true
    }
}

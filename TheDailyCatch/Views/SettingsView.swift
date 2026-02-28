import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLifeStage: LifeStage?
    @State private var selectedTopics: Set<TopicInterest>
    @State private var selectedMotivation: ReadingMotivation?
    @State private var expandedSection: Int? = nil
    var onSave: () -> Void
    var onReset: () -> Void

    init(onSave: @escaping () -> Void, onReset: @escaping () -> Void = {}) {
        let prefs = UserPreferencesService.shared
        _selectedLifeStage = State(initialValue: prefs.selectedLifeStage)
        _selectedTopics = State(initialValue: Set(prefs.selectedTopics))
        _selectedMotivation = State(initialValue: prefs.selectedMotivation)
        self.onSave = onSave
        self.onReset = onReset
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "E8E7E5")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom header
                    HStack {
                        Text("CANCEL")
                            .font(AppTheme.mono(14, weight: .bold))
                            .foregroundStyle(AppTheme.textDark.opacity(0.6))
                            .onTapGesture { dismiss() }

                        Spacer()

                        Text("SETTINGS")
                            .font(AppTheme.mono(14, weight: .bold))
                            .foregroundStyle(AppTheme.textDark)

                        Spacer()

                        Text("SAVE")
                            .font(AppTheme.mono(14, weight: .bold))
                            .foregroundStyle(Color(hex: "5D84C4"))
                            .onTapGesture {
                                let prefs = UserPreferencesService.shared
                                let changed = prefs.selectedLifeStage != selectedLifeStage
                                    || Set(prefs.selectedTopics) != selectedTopics
                                    || prefs.selectedMotivation != selectedMotivation
                                prefs.selectedLifeStage = selectedLifeStage
                                prefs.selectedTopics = Array(selectedTopics)
                                prefs.selectedMotivation = selectedMotivation
                                dismiss()
                                if changed {
                                    onSave()
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Section 1: Life Stage
                        collapsibleSection(
                            index: 1,
                            title: "WHERE ARE YOU RIGHT NOW?",
                            summary: selectedLifeStage?.displayName ?? "Not set"
                        ) {
                            VStack(spacing: 10) {
                                ForEach(LifeStage.allCases) { stage in
                                    settingsRow(
                                        emoji: stage.emoji,
                                        label: stage.displayName.uppercased(),
                                        isSelected: selectedLifeStage == stage
                                    ) {
                                        selectedLifeStage = stage
                                    }
                                }
                            }
                        }

                        // Section 2: Topics
                        collapsibleSection(
                            index: 2,
                            title: "WHAT DO YOU ACTUALLY CARE ABOUT?",
                            summary: "\(selectedTopics.count) selected"
                        ) {
                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(TopicInterest.allCases) { topic in
                                        let isSelected = selectedTopics.contains(topic)
                                        Button {
                                            if isSelected {
                                                if selectedTopics.count > 1 {
                                                    selectedTopics.remove(topic)
                                                }
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
                                            .padding(.vertical, 14)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(isSelected ? Color(hex: "CEDCE9") : Color(hex: "F2F2F2"))
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                            .shadow(color: Color.black.opacity(0.25), radius: 2, x: 2, y: 2)
                                        }
                                    }
                                }
                                .padding(.bottom, 6)
                            }
                            .padding(.horizontal, 6)
                            .scrollIndicators(.visible)
                            .frame(maxHeight: 420)
                            .padding(.horizontal, -6)
                        }

                        // Section 3: Motivation
                        collapsibleSection(
                            index: 3,
                            title: "WHY DO YOU WANT TO STAY INFORMED?",
                            summary: selectedMotivation?.displayName ?? "Not set"
                        ) {
                            VStack(spacing: 10) {
                                ForEach(ReadingMotivation.allCases) { motivation in
                                    settingsRow(
                                        emoji: motivation.emoji,
                                        label: motivation.displayName.uppercased(),
                                        isSelected: selectedMotivation == motivation
                                    ) {
                                        selectedMotivation = motivation
                                    }
                                }
                            }
                        }

                        // Restart App
                        Button {
                            UserPreferencesService.shared.isOnboardingComplete = false
                            dismiss()
                            onReset()
                        } label: {
                            Text("RESTART APP")
                                .font(AppTheme.mono(14, weight: .bold))
                                .foregroundStyle(AppTheme.textDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 2, y: 2)
                        }
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 30)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                } // VStack
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Collapsible Section

    private func collapsibleSection<Content: View>(
        index: Int,
        title: String,
        summary: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                expandedSection = expandedSection == index ? nil : index
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(AppTheme.headline(16, weight: .bold))
                            .foregroundStyle(AppTheme.textDark)
                            .multilineTextAlignment(.leading)
                        if expandedSection != index {
                            Text(summary)
                                .font(.custom("SpaceGrotesk-Light", size: 13).weight(.medium))
                                .foregroundStyle(AppTheme.textDark.opacity(0.5))
                        }
                    }
                    Spacer()
                    Image(systemName: expandedSection == index ? "chevron.up" : "chevron.down")
                        .font(.body.weight(.medium))
                        .foregroundStyle(AppTheme.textDark.opacity(0.4))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 2, y: 2)
            }

            if expandedSection == index {
                content()
            }
        }
    }

    // MARK: - Settings Row (single select)

    private func settingsRow(emoji: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color(hex: "CEDCE9") : Color(hex: "F2F2F2"))
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: Color.black.opacity(0.25), radius: 2, x: 2, y: 2)
        }
    }
}

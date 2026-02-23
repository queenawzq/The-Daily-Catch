import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedModes: Set<IdentityMode>
    @State private var selectedEnergy: EnergyMode
    var onSave: () -> Void

    init(onSave: @escaping () -> Void) {
        let prefs = UserPreferencesService.shared
        _selectedModes = State(initialValue: Set(prefs.selectedIdentityModes))
        _selectedEnergy = State(initialValue: prefs.selectedEnergyMode)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Identity modes
                        sectionHeader("Your Identity")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(IdentityMode.allCases) { mode in
                                IdentityCard(
                                    mode: mode,
                                    isSelected: selectedModes.contains(mode)
                                ) {
                                    if selectedModes.contains(mode) {
                                        if selectedModes.count > 1 {
                                            selectedModes.remove(mode)
                                        }
                                    } else {
                                        selectedModes.insert(mode)
                                    }
                                }
                            }
                        }

                        // Energy mode
                        sectionHeader("Energy Level")
                        HStack(spacing: 12) {
                            ForEach(EnergyMode.allCases) { mode in
                                Button {
                                    selectedEnergy = mode
                                } label: {
                                    VStack(spacing: 6) {
                                        Text(mode.emoji)
                                            .font(.title)
                                        Text(mode.displayName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(AppTheme.textPrimary)
                                        Text(mode == .quick ? "~30 words" : "~100 words")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedEnergy == mode ? AppTheme.accent.opacity(0.3) : AppTheme.cardBackground)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedEnergy == mode ? AppTheme.accent : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }

                        // About
                        sectionHeader("About")
                        Text("The Daily Catch delivers your personalized news brief powered by AI. Stories are fetched in real-time and summarized just for you.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let prefs = UserPreferencesService.shared
                        prefs.selectedIdentityModes = Array(selectedModes)
                        prefs.selectedEnergyMode = selectedEnergy
                        dismiss()
                        onSave()
                    }
                    .foregroundStyle(AppTheme.accent)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppTheme.textPrimary)
    }
}

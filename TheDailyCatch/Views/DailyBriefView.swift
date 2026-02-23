import SwiftUI

struct DailyBriefView: View {
    @Bindable var viewModel: DailyBriefViewModel
    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else if viewModel.isComplete {
                CompletionView {
                    Task { await viewModel.refreshBrief() }
                } onRestart: {
                    viewModel.restart()
                }
            } else if !viewModel.stories.isEmpty {
                cardStack
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView {
                Task { await viewModel.refreshBrief() }
            }
        }
        .task {
            await viewModel.loadBrief()
        }
    }

    private var cardStack: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                energyToggle
                Spacer()
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // Swipeable cards
            TabView(selection: Binding(
                get: { viewModel.currentIndex },
                set: { newValue in
                    viewModel.currentIndex = newValue
                    if newValue >= viewModel.stories.count {
                        viewModel.currentIndex = viewModel.stories.count
                    }
                }
            )) {
                ForEach(Array(viewModel.stories.enumerated()), id: \.element.id) { index, story in
                    StoryCardView(
                        story: story,
                        progress: "\(index + 1) of \(viewModel.stories.count)"
                    )
                    .tag(index)
                }

                // Completion page at end
                CompletionView {
                    Task { await viewModel.refreshBrief() }
                } onRestart: {
                    viewModel.restart()
                }
                .tag(viewModel.stories.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    private var energyToggle: some View {
        HStack(spacing: 4) {
            ForEach(EnergyMode.allCases) { mode in
                Button {
                    UserPreferencesService.shared.selectedEnergyMode = mode
                    Task { await viewModel.refreshBrief() }
                } label: {
                    Text("\(mode.emoji) \(mode.displayName)")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            UserPreferencesService.shared.selectedEnergyMode == mode
                                ? AppTheme.accent.opacity(0.3)
                                : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppTheme.accent)
            Text("Catching your stories...")
                .font(.headline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.accent)
            Text("Oops, something went wrong")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            Button("Try again") {
                Task { await viewModel.refreshBrief() }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
        }
        .padding()
    }
}

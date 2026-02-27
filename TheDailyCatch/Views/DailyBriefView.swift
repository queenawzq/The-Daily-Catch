import SwiftUI

struct DailyBriefView: View {
    @Bindable var viewModel: DailyBriefViewModel
    var onReset: () -> Void = {}
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "E8E7E5")
                .ignoresSafeArea()

            Image("SummaryPageBackground")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else if !viewModel.stories.isEmpty {
                mainFeed
            }

            // Story detail overlay
            if let story = viewModel.expandedStory {
                StoryDetailView(
                    stories: viewModel.stories,
                    initialIndex: (viewModel.stories.firstIndex(where: { $0.id == story.id }) ?? 0),
                    onClose: { viewModel.collapseStory() },
                    onStoryViewed: { viewModel.markRead($0) }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(onSave: {
                Task { await viewModel.refreshBrief() }
            }, onReset: onReset)
            .presentationCornerRadius(12)
        }
        .task {
            await viewModel.loadBrief()
        }
    }

    private func storyNumber(for story: Story) -> Int {
        (viewModel.stories.firstIndex(where: { $0.id == story.id }) ?? 0) + 1
    }

    // MARK: - Main Feed

    private var mainFeed: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                topBar
                greetingSection
                progressSection

                storyList

                if viewModel.allRead {
                    HStack(spacing: 10) {
                        Image("CaughtUpIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .offset(y: -4)

                        Text("YOU ARE ALL CAUGHT UP.")
                            .font(AppTheme.headline(16, weight: .bold))
                            .foregroundStyle(AppTheme.textDark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(alignment: .center) {
            Image("SmallLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 62)

            Spacer()

            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(AppTheme.textDark)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .padding(.top, -8)
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        VStack(spacing: 4) {
            HStack(alignment: .center) {
                Image("TodaysCatch")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                    .offset(y: 4)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.stories.count) stories  |  ~ 2 min")
                        .font(.custom("SpaceGrotesk-Light", size: 13).weight(.medium))
                        .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    Text(currentDateTimeString)
                        .font(.custom("SpaceGrotesk-Light", size: 13).weight(.medium))
                        .foregroundStyle(AppTheme.textDark.opacity(0.6))
                }
                .offset(y: -3)
                .padding(.trailing, 20)
            }
            .padding(.top, 4)
        }
        .padding(.bottom, 6)
    }

    private var currentDateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a 'ET'"
        return formatter.string(from: Date())
    }

    // MARK: - Progress

    private var progressSection: some View {
        HStack(spacing: 5) {
            Spacer()

            ForEach(0..<viewModel.stories.count, id: \.self) { index in
                let isRead = viewModel.isRead(viewModel.stories[index])
                Rectangle()
                    .fill(isRead ? Color(hex: "5D84C4") : AppTheme.textDark.opacity(0.15))
                    .frame(width: 20, height: 4)
                    .animation(.spring(response: 0.3), value: isRead)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, -3)
        .padding(.bottom, 18)
    }

    // MARK: - Story List

    private var storyList: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(viewModel.stories.enumerated()), id: \.element.id) { index, story in
                StoryCardView(
                    story: story,
                    storyNumber: index + 1,
                    isRead: viewModel.isRead(story)
                ) {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.expandStory(story)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Inline Completion

    private var inlineCompletionSection: some View {
        VStack(spacing: 16) {
            Image("CaughtUpIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .padding(.top, 32)

            Text("Consider yourself caught up.")
                .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                .foregroundStyle(AppTheme.textDark.opacity(0.6))

            Text("NEXT CATCH TOMORROW")
                .font(AppTheme.mono(11, weight: .bold))
                .foregroundStyle(AppTheme.textDark.opacity(0.4))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.6))
                .clipShape(Capsule())

            Button {
                Task { await viewModel.refreshBrief() }
            } label: {
                Text("WANT MORE?")
                    .font(AppTheme.mono(13, weight: .bold))
                    .foregroundStyle(Color(hex: "5D84C4"))
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Loading / Error

    private var loadingView: some View {
        ZStack {
            Color(hex: "E8E7E5")
                .ignoresSafeArea()
            VStack(spacing: 20) {
                FishingAnimationView()
                    .frame(width: 120, height: 120)
                Text("Catching your stories...")
                    .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.5))
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.accentRed)
            Text("Oops, something went wrong")
                .font(AppTheme.headline(18))
                .foregroundStyle(AppTheme.textDark)
            Text(message)
                .font(.custom("SpaceGrotesk-Light", size: 13).weight(.medium))
                .foregroundStyle(AppTheme.textDark.opacity(0.5))
                .multilineTextAlignment(.center)
            Button("Try again") {
                Task { await viewModel.refreshBrief() }
            }
            .font(AppTheme.mono(14, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppTheme.textDark)
            .clipShape(Capsule())
        }
        .padding()
    }
}

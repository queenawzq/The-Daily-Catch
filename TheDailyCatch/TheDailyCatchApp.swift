import SwiftUI

enum AppState {
    case splash
    case onboardingIntro
    case onboardingQuestions
    case onboardingNotifications
    case onboardingComplete
    case mainFeed
}

@main
struct TheDailyCatchApp: App {
    @State private var appState: AppState = UserPreferencesService.shared.isOnboardingComplete ? .mainFeed : .splash
    @State private var viewModel = DailyBriefViewModel()
    @State private var storeManager = StoreManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                switch appState {
                case .splash:
                    SplashView {
                        withAnimation { appState = .onboardingIntro }
                    }

                case .onboardingIntro:
                    OnboardingIntroView {
                        withAnimation { appState = .onboardingQuestions }
                    }

                case .onboardingQuestions:
                    OnboardingView {
                        withAnimation { appState = .onboardingNotifications }
                    }

                case .onboardingNotifications:
                    OnboardingNotificationsView {
                        withAnimation { appState = .onboardingComplete }
                    }

                case .onboardingComplete:
                    OnboardingCompleteView {
                        BriefCacheService.shared.clearCache()
                        viewModel = DailyBriefViewModel()
                        withAnimation { appState = .mainFeed }
                    }

                case .mainFeed:
                    DailyBriefView(viewModel: viewModel, onReset: {
                        withAnimation { appState = .splash }
                    })
                        .preferredColorScheme(.dark)
                }
            }
            .environment(storeManager)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task { await NotificationService.shared.syncWithPreferences() }
                }
            }
        }
    }
}

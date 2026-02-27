import SwiftUI

enum AppState {
    case splash
    case onboardingIntro
    case onboardingQuestions
    case onboardingComplete
    case mainFeed
}

@main
struct TheDailyCatchApp: App {
    @State private var appState: AppState = UserPreferencesService.shared.isOnboardingComplete ? .mainFeed : .splash
    @State private var viewModel = DailyBriefViewModel()

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
                        withAnimation { appState = .onboardingComplete }
                    }

                case .onboardingComplete:
                    OnboardingCompleteView {
                        withAnimation { appState = .mainFeed }
                    }

                case .mainFeed:
                    DailyBriefView(viewModel: viewModel, onReset: {
                        withAnimation { appState = .splash }
                    })
                        .preferredColorScheme(.dark)
                }
            }
        }
    }
}

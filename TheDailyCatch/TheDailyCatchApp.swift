import SwiftUI

@main
struct TheDailyCatchApp: App {
    @State private var showOnboarding = !UserPreferencesService.shared.isOnboardingComplete
    @State private var viewModel = DailyBriefViewModel()

    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView {
                    withAnimation {
                        showOnboarding = false
                    }
                }
                .preferredColorScheme(.dark)
            } else {
                DailyBriefView(viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

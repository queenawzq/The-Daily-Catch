import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @Environment(StoreManager.self) private var storeManager
    @State private var showPaywall = false
    @State private var pricingIsYearly = true
    @State private var selectedLifeStage: LifeStage?
    @State private var rankedTopics: [TopicInterest]
    @State private var selectedMotivation: ReadingMotivation?
    @State private var expandedSection: Int? = nil
    @State private var showTestCodeAlert = false
    @State private var testCodeInput = ""
    @State private var testCodeMessage: String?
    @State private var showTestCodeResult = false
    var onSave: () -> Void
    var onReset: () -> Void

    private let ctaBlue = Color(hex: "375BCD")

    init(onSave: @escaping () -> Void, onReset: @escaping () -> Void = {}) {
        let prefs = UserPreferencesService.shared
        _selectedLifeStage = State(initialValue: prefs.selectedLifeStage)
        _rankedTopics = State(initialValue: Array(prefs.selectedTopics.prefix(3)))
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
                            .foregroundStyle(ctaBlue)
                            .onTapGesture {
                                let prefs = UserPreferencesService.shared
                                let changed = prefs.selectedLifeStage != selectedLifeStage
                                    || prefs.selectedTopics != rankedTopics
                                    || prefs.selectedMotivation != selectedMotivation
                                prefs.selectedLifeStage = selectedLifeStage
                                prefs.selectedTopics = rankedTopics
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
                    VStack(alignment: .leading, spacing: 0) {

                        // ── SUBSCRIPTION CARD ──
                        planCard
                            .padding(.bottom, 32)

                        // ── MY PREFERENCES ──
                        Text("MY PREFERENCES")
                            .font(AppTheme.mono(10))
                            .foregroundStyle(AppTheme.textMidGrey)
                            .padding(.leading, 4)
                            .padding(.bottom, 12)

                        VStack(spacing: 10) {
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

                            collapsibleSection(
                                index: 2,
                                title: "WHAT DO YOU ACTUALLY CARE ABOUT?",
                                summary: rankedTopics.map(\.displayName).joined(separator: " > ")
                            ) {
                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(TopicInterest.allCases) { topic in
                                            let rank = rankedTopics.firstIndex(of: topic)
                                            let isSelected = rank != nil
                                            Button {
                                                if let rank = rank {
                                                    rankedTopics.remove(at: rank)
                                                } else if rankedTopics.count < 3 {
                                                    rankedTopics.append(topic)
                                                }
                                            } label: {
                                                HStack(spacing: 14) {
                                                    Text(topic.emoji)
                                                        .font(.title2)
                                                    Text(topic.displayName.uppercased())
                                                        .font(AppTheme.mono(13, weight: .bold))
                                                        .foregroundStyle(AppTheme.textDark)
                                                    Spacer()
                                                    if let rank = rank {
                                                        Text("\(rank + 1)")
                                                            .font(AppTheme.mono(14, weight: .bold))
                                                            .foregroundStyle(.white)
                                                            .frame(width: 28, height: 28)
                                                            .background(Circle().fill(Color(hex: "5D84C4")))
                                                    } else {
                                                        Circle()
                                                            .strokeBorder(AppTheme.textMidGrey.opacity(0.4), lineWidth: 1.5)
                                                            .frame(width: 28, height: 28)
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
                                            .opacity(rankedTopics.count >= 3 && !isSelected ? 0.5 : 1.0)
                                        }
                                    }
                                    .padding(.bottom, 6)
                                }
                                .padding(.horizontal, 6)
                                .scrollIndicators(.visible)
                                .frame(maxHeight: 420)
                                .padding(.horizontal, -6)
                            }

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
                        }
                        .padding(.bottom, 32)

                        // ── FEEDBACK & SUPPORT ──
                        Text("FEEDBACK & SUPPORT")
                            .font(AppTheme.mono(10))
                            .foregroundStyle(AppTheme.textMidGrey)
                            .padding(.leading, 4)
                            .padding(.bottom, 12)

                        VStack(spacing: 8) {
                            actionRow(
                                icon: "star",
                                iconColor: Color(hex: "D4772C"),
                                iconBg: AppTheme.orangeSoft,
                                label: "Rate The Daily Catch",
                                sublabel: "Enjoying it? A review helps us a lot"
                            ) {
                                requestReview()
                            }

                            actionRow(
                                icon: "bubble.left",
                                iconColor: AppTheme.textMidGrey,
                                iconBg: Color(hex: "F2EFEA"),
                                label: "Share feedback",
                                sublabel: "Tell us what's working and what's not"
                            ) {
                                if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdxbZOyQXOcn784TUnm6y9gh8x2JxnJu9mXC_3HXTRVGk5Ajg/viewform?usp=dialog") {
                                    UIApplication.shared.open(url)
                                }
                            }

                            actionRow(
                                icon: "heart",
                                iconColor: AppTheme.textMidGrey,
                                iconBg: Color(hex: "F2EFEA"),
                                label: "Share with a friend",
                                sublabel: "Know someone who'd love this?"
                            ) {
                                let url = URL(string: "https://apps.apple.com/us/app/the-daily-catch-news-reader/id6759816685")!
                                let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let root = scene.windows.first?.rootViewController {
                                    // Walk up to the topmost presented VC (needed when inside a sheet)
                                    var topVC = root
                                    while let presented = topVC.presentedViewController {
                                        topVC = presented
                                    }
                                    topVC.present(av, animated: true)
                                }
                            }
                        }
                        .padding(.bottom, 32)

                        // ── BETA TESTING ──
                        Text("BETA TESTING")
                            .font(AppTheme.mono(10))
                            .foregroundStyle(AppTheme.textMidGrey)
                            .padding(.leading, 4)
                            .padding(.bottom, 12)

                        VStack(spacing: 8) {
                            if let expiryStr = storeManager.betaExpiryString {
                                actionRow(
                                    icon: "checkmark.seal",
                                    iconColor: Color(hex: "5BA89E"),
                                    iconBg: Color(hex: "E8F5F1"),
                                    label: "Beta access active",
                                    sublabel: "Deep Catch unlocked until \(expiryStr)"
                                ) { }
                            }

                            actionRow(
                                icon: "key",
                                iconColor: Color(hex: "5B7FBF"),
                                iconBg: Color(hex: "EBF0F8"),
                                label: "Enter test code",
                                sublabel: "Unlock Deep Catch for testing"
                            ) {
                                testCodeInput = ""
                                showTestCodeAlert = true
                            }
                        }
                        .padding(.bottom, 32)

                        // ── RESTART APP ──
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

                        // ── VERSION ──
                        Text("The Daily Catch v1.8 · Stay informed, not overwhelmed.")
                            .font(AppTheme.mono(9))
                            .lineLimit(1)
                            .foregroundStyle(AppTheme.textDark.opacity(0.3))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 30)
                    .padding(.top, 16)
                }
                } // VStack
            }
            .navigationBarHidden(true)
            .alert("Enter Test Code", isPresented: $showTestCodeAlert) {
                TextField("Code", text: $testCodeInput)
                    .textInputAutocapitalization(.characters)
                Button("Cancel", role: .cancel) { }
                Button("Redeem") {
                    let code = testCodeInput
                    Task {
                        do {
                            let expiry = try await storeManager.redeemTestCode(code)
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            testCodeMessage = "Deep Catch unlocked until \(formatter.string(from: expiry))"
                        } catch {
                            testCodeMessage = error.localizedDescription
                        }
                        showTestCodeResult = true
                    }
                }
            } message: {
                Text("If you're a tester, enter the code that's been provided to you.")
            }
            .alert("Test Code", isPresented: $showTestCodeResult) {
                Button("OK") { }
            } message: {
                Text(testCodeMessage ?? "")
            }
        }
    }

    // MARK: - Plan Card

    private var renewalDateString: String {
        let calendar = Calendar.current
        let renewalDate = calendar.date(byAdding: pricingIsYearly ? .year : .month, value: 1, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: renewalDate)
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR PLAN")
                        .font(AppTheme.headline(14, weight: .bold))
                        .foregroundStyle(AppTheme.textDark)

                    Text(storeManager.isPremium ? "Deep Catch" : "Daily Catch Free")
                        .font(AppTheme.body(14).weight(.medium))
                        .foregroundStyle(storeManager.isPremium ? ctaBlue : AppTheme.textMidGrey)
                }

                Spacer()

                Text(storeManager.isPremium ? "ACTIVE" : "FREE")
                    .font(AppTheme.mono(10))
                    .foregroundStyle(storeManager.isPremium ? ctaBlue : AppTheme.textMidGrey)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(storeManager.isPremium ? ctaBlue.opacity(0.12) : Color(hex: "F2EFEA"))
                    )
            }

            if storeManager.isPremium {
                Text("Renews \(renewalDateString) · \(pricingIsYearly ? "$29.99/year" : "$3.99/month")")
                    .font(AppTheme.body(11).weight(.medium))
                    .foregroundStyle(AppTheme.textMidGrey)
                    .padding(.top, 8)
            }

            // Divider
            Rectangle()
                .fill(Color(hex: "E8E4DD"))
                .frame(height: 1)
                .padding(.vertical, 16)

            if storeManager.isPremium {
                // Manage subscription
                Button {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Text("Manage subscription")
                            .font(AppTheme.body(14).weight(.semibold))
                            .foregroundStyle(AppTheme.textDark)
                        Spacer()
                        Image("ExternalLinkIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(AppTheme.textDark.opacity(0.3))
                    }
                }
                .buttonStyle(.plain)

                Text("Subscriptions are managed through your Apple ID")
                    .font(AppTheme.body(11).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.3))
                    .padding(.top, 8)

                // Legal links
                HStack(spacing: 16) {
                    Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Link("Privacy Policy", destination: URL(string: "https://www.hexagontechnologies.io/copy-of-privacy-policy-1")!)
                }
                .font(AppTheme.mono(10))
                .foregroundStyle(AppTheme.textDark.opacity(0.45))
                .padding(.top, 8)
            } else {
                // Free user: unlock prompt
                Text("Unlock Deep mode — backstory, full coverage, timelines, and more on every story.")
                    .font(AppTheme.body(13).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    .lineSpacing(3)
                    .padding(.bottom, 12)

                Button {
                    showPaywall = true
                } label: {
                    Text("Try Deep Catch free for 7 days")
                        .font(AppTheme.body(14).weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ctaBlue)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    Task { await storeManager.restorePurchases() }
                } label: {
                    Text("Restore Purchases")
                        .font(AppTheme.body(13).weight(.medium))
                        .foregroundStyle(ctaBlue)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)

                // Legal links
                HStack(spacing: 16) {
                    Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Link("Privacy Policy", destination: URL(string: "https://www.hexagontechnologies.io/copy-of-privacy-policy-1")!)
                }
                .font(AppTheme.mono(10))
                .foregroundStyle(AppTheme.textDark.opacity(0.45))
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
        )
        .fullScreenCover(isPresented: $showPaywall) {
            ZStack {
                Color(hex: "E8E7E5").ignoresSafeArea()
                VStack {
                    Spacer()
                    PaywallOverlayView(
                        paperBgColor: Color(hex: "E8E7E5"),
                        pricingIsYearly: $pricingIsYearly,
                        storeManager: storeManager,
                        onDismiss: {
                            showPaywall = false
                        }
                    )
                }
            }
        }
        .onChange(of: storeManager.isPremium) { _, newValue in
            if newValue {
                showPaywall = false
            }
        }
    }

    // MARK: - Action Row

    private func actionRow(icon: String, iconColor: Color, iconBg: Color, label: String, sublabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBg)
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(AppTheme.body(14).weight(.semibold))
                        .foregroundStyle(AppTheme.textDark)
                    Text(sublabel)
                        .font(AppTheme.body(11).weight(.medium))
                        .foregroundStyle(AppTheme.textMidGrey)
                        .lineLimit(1)
                }

                Spacer()

                Image("ExternalLinkIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(AppTheme.textDark.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
        }
        .buttonStyle(.plain)
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
                                .font(AppTheme.body(13).weight(.medium))
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
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                )
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

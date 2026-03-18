import SwiftUI
import StoreKit

// MARK: - Deep Dive View

struct DeepDiveView: View {
    let keyStat: KeyStat?
    let keyFacts: [String]?
    let deepDive: String
    let linkedTerms: [LinkedTerm]?

    private let darkText = Color(hex: "2A2A2A")
    private let statBg = Color(hex: "FFF0EB")
    private let statNumber = Color(hex: "A0432E")

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key facts")
                .font(.custom("SpaceGrotesk-Light", size: 13.5).weight(.bold))
                .foregroundStyle(darkText)

            // Key stat card
            if let stat = keyStat {
                HStack(alignment: .top, spacing: 14) {
                    Text(cleanText(stat.number))
                        .font(.custom("Lora", size: 42).weight(.bold))
                        .foregroundStyle(statNumber)
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(cleanText(stat.context))
                        .font(AppTheme.body(14).weight(.medium))
                        .foregroundStyle(darkText.opacity(0.6))
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(statBg)
                )
            }

            // Key facts list
            if let facts = keyFacts, !facts.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(facts.enumerated()), id: \.offset) { _, fact in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\u{2192}")
                                .font(AppTheme.body(15.5).weight(.medium))
                                .foregroundStyle(darkText.opacity(0.3))

                            Text(cleanText(fact))
                                .font(AppTheme.body(15.5).weight(.medium))
                                .foregroundStyle(darkText.opacity(0.65))
                                .lineSpacing(5)
                        }
                    }
                }
            } else {
                // Fallback to deepDive prose
                if let terms = linkedTerms, !terms.isEmpty {
                    AnnotatedTextView(text: cleanText(deepDive), terms: terms)
                } else {
                    Text(cleanText(deepDive))
                        .font(AppTheme.body(15.5).weight(.medium))
                        .foregroundStyle(darkText.opacity(0.65))
                        .lineSpacing(5)
                }
            }
        }
    }
}

// MARK: - Timeline View

struct TimelineView: View {
    let events: [TimelineEvent]
    @State private var isExpanded = false

    private let darkText = Color(hex: "2A2A2A")
    private let timelineBlue = Color(hex: "5B7FBF")
    private let borderColor = Color(hex: "E0E0E0")

    /// Always show newest first
    private var sortedEvents: [TimelineEvent] {
        events.reversed()
    }

    var body: some View {
        if !events.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("How we got here")
                        .font(.custom("SpaceGrotesk-Light", size: 13.5).weight(.bold))
                        .foregroundStyle(darkText)

                    Spacer()

                    if sortedEvents.count > 1 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Text(isExpanded ? "COLLAPSE ▲" : "\(sortedEvents.count - 1) MORE ▾")
                                .font(AppTheme.mono(10))
                                .foregroundStyle(darkText.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Timeline card — tap anywhere to expand/collapse
                VStack(alignment: .leading, spacing: 0) {
                    let visibleEvents = isExpanded ? sortedEvents : Array(sortedEvents.prefix(1))
                    ForEach(Array(visibleEvents.enumerated()), id: \.offset) { index, event in
                        HStack(alignment: .top, spacing: 12) {
                            // Dot and line
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(timelineBlue)
                                    .frame(width: 8, height: 8)
                                if index < visibleEvents.count - 1 {
                                    Rectangle()
                                        .fill(borderColor)
                                        .frame(width: 1)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.date)
                                    .font(AppTheme.mono(11))
                                    .foregroundStyle(timelineBlue)
                                Text(cleanText(event.description))
                                    .font(AppTheme.body(15.5).weight(.medium))
                                    .foregroundStyle(darkText.opacity(0.65))
                                    .lineSpacing(5)
                            }
                            .padding(.bottom, index < visibleEvents.count - 1 ? 16 : 0)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor, lineWidth: 1)
                        )
                )
                .onTapGesture {
                    if sortedEvents.count > 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }
                }
            }
        }
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

// MARK: - Full Coverage View

struct FullCoverageView: View {
    let sources: [SourceCoverage]
    @Binding var isScrolling: Bool
    @State private var selectedIndex: Int? = nil

    private let darkText = Color(hex: "2A2A2A")

    var body: some View {
        if !sources.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("Full coverage")
                        .font(.custom("SpaceGrotesk-Light", size: 13.5).weight(.bold))
                        .foregroundStyle(darkText)

                    Spacer()

                    Text("SWIPE →")
                        .font(AppTheme.mono(10))
                        .foregroundStyle(darkText.opacity(0.4))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(sources.enumerated()), id: \.offset) { index, source in
                            SourceCard(source: source)
                                .onTapGesture {
                                    selectedIndex = index
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { _ in isScrolling = true }
                        .onEnded { _ in isScrolling = false }
                )
            }
            .fullScreenCover(item: $selectedIndex) { index in
                SourceDetailView(sources: sources, initialIndex: index)
            }
        }
    }
}

private struct SourceCard: View {
    let source: SourceCoverage
    private let darkText = Color(hex: "2A2A2A")
    private let borderColor = Color(hex: "E0E0E0")

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(source.name)
                    .font(AppTheme.body(14).weight(.bold))
                    .foregroundStyle(darkText)

                Spacer()

                stanceBadge
            }

            Text(source.angle)
                .font(AppTheme.body(15.5).weight(.medium))
                .foregroundStyle(darkText.opacity(0.65))
                .lineSpacing(5)
                .lineLimit(2)
        }
        .padding(14)
        .frame(width: 260, alignment: .topLeading)
        .frame(minHeight: 110, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var stanceBadge: some View {
        let (bg, fg) = stanceColors(source.stance)
        Text(source.stance)
            .font(AppTheme.mono(9))
            .foregroundStyle(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(bg))
    }

    private func stanceColors(_ stance: String) -> (Color, Color) {
        switch stance {
        case "Analytical": return (Color(hex: "E0EAFF"), Color(hex: "3B5998"))
        case "Critical":   return (Color(hex: "FFF0E0"), Color(hex: "D4772C"))
        case "Positive":   return (Color(hex: "E0F5E8"), Color(hex: "2D8A4E"))
        default:           return (Color(hex: "F0F0F0"), Color(hex: "666666")) // Neutral
        }
    }
}

// MARK: - Source Detail View

struct SourceDetailView: View {
    let sources: [SourceCoverage]
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int

    private let darkText = Color(hex: "2A2A2A")
    private let paperBg = Color(hex: "F5F1EB")

    init(sources: [SourceCoverage], initialIndex: Int) {
        self.sources = sources
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }

    private var source: SourceCoverage { sources[currentIndex] }

    var body: some View {
        ZStack {
            paperBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Top bar: source name + stance + close
                    HStack(alignment: .center) {
                        Text(source.name)
                            .font(AppTheme.body(15).weight(.bold))
                            .foregroundStyle(darkText)

                        stanceBadge

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Text("CLOSE")
                                .font(AppTheme.mono(12))
                                .foregroundStyle(darkText.opacity(0.5))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(hex: "D0D0D0"), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    // Divider
                    Rectangle()
                        .fill(darkText.opacity(0.1))
                        .frame(height: 1)

                    // Headline
                    if let headline = source.headline, !headline.isEmpty {
                        Text(headline.uppercased())
                            .font(AppTheme.headline(26, weight: .bold))
                            .foregroundStyle(darkText)
                            .lineSpacing(2)
                    }

                    // Summary paragraphs
                    if let summary = source.summary, !summary.isEmpty {
                        let paragraphs = summary.components(separatedBy: "\n\n").filter { !$0.isEmpty }
                        if paragraphs.count > 1 {
                            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                                Text(paragraph.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .font(AppTheme.body(15.5).weight(.medium))
                                    .foregroundStyle(darkText.opacity(0.65))
                                    .lineSpacing(5)
                            }
                        } else {
                            Text(summary)
                                .font(AppTheme.body(15.5).weight(.medium))
                                .foregroundStyle(darkText.opacity(0.65))
                                .lineSpacing(5)
                        }
                    } else {
                        Text(source.angle)
                            .font(AppTheme.body(15.5).weight(.medium))
                            .foregroundStyle(darkText.opacity(0.65))
                            .lineSpacing(5)
                    }

                    // Source attribution
                    Rectangle()
                        .fill(darkText.opacity(0.08))
                        .frame(height: 1)
                        .padding(.top, 8)

                    HStack(spacing: 8) {
                        Image("PaperClamp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)

                        Text(source.name + (source.date != nil ? " — as of \(source.date!)" : ""))
                            .font(AppTheme.body(11))
                            .foregroundStyle(AppTheme.textMidGrey)
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            .id(currentIndex)

            // Page indicator dots
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    ForEach(0..<sources.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? darkText : darkText.opacity(0.25))
                            .frame(width: 5, height: 5)
                    }
                }
                .padding(.vertical, 12)
                .padding(.bottom, 16)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    let horizontal = value.translation.width
                    if abs(horizontal) > abs(value.translation.height) && abs(horizontal) > 80 {
                        if horizontal < 0 && currentIndex < sources.count - 1 {
                            withAnimation { currentIndex += 1 }
                        } else if horizontal > 0 && currentIndex > 0 {
                            withAnimation { currentIndex -= 1 }
                        }
                    }
                }
        )
    }

    @ViewBuilder
    private var stanceBadge: some View {
        let (bg, fg) = stanceColors(source.stance)
        Text(source.stance)
            .font(AppTheme.mono(9))
            .foregroundStyle(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(bg))
    }

    private func stanceColors(_ stance: String) -> (Color, Color) {
        switch stance {
        case "Analytical": return (Color(hex: "E0EAFF"), Color(hex: "3B5998"))
        case "Critical":   return (Color(hex: "FFF0E0"), Color(hex: "D4772C"))
        case "Positive":   return (Color(hex: "E0F5E8"), Color(hex: "2D8A4E"))
        default:           return (Color(hex: "F0F0F0"), Color(hex: "666666"))
        }
    }
}

// MARK: - What to Watch View

struct WhatToWatchView: View {
    let text: String
    private let darkText = Color(hex: "2A2A2A")

    var body: some View {
        if !text.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("What to watch")
                    .font(.custom("SpaceGrotesk-Light", size: 13.5).weight(.bold))
                    .foregroundStyle(AppTheme.orangeAccent)

                Text(cleanText(text))
                    .font(AppTheme.body(15.5).weight(.medium))
                    .foregroundStyle(darkText.opacity(0.65))
                    .lineSpacing(5)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.orangeSoft)
            )
        }
    }
}

// MARK: - Annotated Text View (inline linked terms)

struct AnnotatedTextView: View {
    let text: String
    let terms: [LinkedTerm]
    @State private var expandedTerm: LinkedTerm?

    private let darkText = Color(hex: "2A2A2A")
    private let termBlue = Color(hex: "5B7FBF")
    private let cardBg = Color(hex: "EBF1FB")

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(annotatedText)
                .font(AppTheme.body(15.5).weight(.medium))
                .foregroundStyle(darkText.opacity(0.65))
                .lineSpacing(5)
                .tint(darkText.opacity(0.65))
                .environment(\.openURL, OpenURLAction { url in
                    let termId = url.absoluteString
                        .replacingOccurrences(of: "term://", with: "")
                        .removingPercentEncoding ?? ""
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if expandedTerm?.term == termId {
                            expandedTerm = nil
                        } else {
                            expandedTerm = terms.first { $0.term == termId }
                        }
                    }
                    return .handled
                })

            if let term = expandedTerm {
                HStack(alignment: .top, spacing: 10) {
                    Rectangle()
                        .fill(termBlue)
                        .frame(width: 3)

                    Text(term.explanation)
                        .font(AppTheme.body(14))
                        .foregroundStyle(darkText.opacity(0.7))
                        .lineSpacing(4)

                    Spacer(minLength: 0)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedTerm = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(darkText.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(cardBg)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var annotatedText: AttributedString {
        var result = AttributedString(text)
        for term in terms {
            var searchStart = result.startIndex
            while searchStart < result.endIndex {
                let remaining = result[searchStart..<result.endIndex]
                guard let range = remaining.range(of: term.term, options: .caseInsensitive) else { break }
                result[range].link = URL(string: "term://" + (term.term.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? term.term))
                result[range].underlineStyle = Text.LineStyle(pattern: .dot)
                result[range].underlineColor = UIColor(termBlue)
                searchStart = range.upperBound
            }
        }
        return result
    }
}

// MARK: - Paywall Overlay View

struct PaywallOverlayView: View {
    let paperBgColor: Color
    @Binding var pricingIsYearly: Bool
    var storeManager: StoreManager
    let onDismiss: () -> Void

    private let darkText = Color(hex: "2A2A2A")
    private let ctaBlue = Color(hex: "375BCD")

    private var selectedProduct: Product? {
        pricingIsYearly ? storeManager.yearlyProduct : storeManager.monthlyProduct
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient fade from transparent to paper bg
            LinearGradient(
                colors: [paperBgColor.opacity(0), paperBgColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)

            // Content on solid bg
            VStack(spacing: 20) {
                // Lock icon
                ZStack {
                    Circle()
                        .fill(ctaBlue.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(ctaBlue)
                }

                Text("WANT THE FULL PICTURE?")
                    .font(AppTheme.headline(22))
                    .foregroundStyle(darkText)

                Text("Deep mode unlocks timelines, source coverage, expert terms, and forward-looking analysis.")
                    .font(AppTheme.body(15.5).weight(.medium))
                    .foregroundStyle(darkText.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Pricing toggle
                HStack(spacing: 0) {
                    pricingPill(label: storeManager.monthlyPriceString + "/mo", subtitle: "Monthly", savingsText: nil, isSelected: !pricingIsYearly) {
                        pricingIsYearly = false
                    }
                    pricingPill(label: storeManager.yearlyPriceString + "/yr", subtitle: "Yearly", savingsText: "Save 37%", isSelected: pricingIsYearly) {
                        pricingIsYearly = true
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "F0F0F0"))
                )

                // CTA button
                Button {
                    guard let product = selectedProduct else {
                        print("[Paywall] No product available. Products loaded: \(storeManager.products.count)")
                        storeManager.purchaseError = "Products not loaded yet. Please try again."
                        Task { await storeManager.loadProducts() }
                        return
                    }
                    print("[Paywall] Purchasing: \(product.id)")
                    Task { await storeManager.purchase(product) }
                } label: {
                    ZStack {
                        Text(storeManager.isEligibleForTrial ? "Try free for 7 days" : "Subscribe")
                            .font(AppTheme.body(16).weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ctaBlue)
                            )
                            .opacity(storeManager.isPurchasing ? 0.5 : 1)

                        if storeManager.isPurchasing {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .disabled(storeManager.isPurchasing)

                if let error = storeManager.purchaseError {
                    Text(error)
                        .font(AppTheme.mono(11))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Text("Cancel anytime · No commitment")
                    .font(AppTheme.mono(10))
                    .foregroundStyle(darkText.opacity(0.35))

                // Dismiss
                Button(action: onDismiss) {
                    Text("Not now — back to Quick")
                        .font(AppTheme.body(13).weight(.medium))
                        .foregroundStyle(darkText.opacity(0.4))
                        .underline()
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
            .background(paperBgColor)
        }
    }

    private func pricingPill(label: String, subtitle: String, savingsText: String?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if let savings = savingsText, isSelected {
                    Text(savings)
                        .font(AppTheme.mono(9))
                        .foregroundStyle(Color(hex: "2D8A4E"))
                }
                Text(label)
                    .font(AppTheme.body(14).weight(.semibold))
                    .foregroundStyle(isSelected ? darkText : darkText.opacity(0.4))
                Text(subtitle)
                    .font(AppTheme.mono(9))
                    .foregroundStyle(isSelected ? darkText.opacity(0.6) : darkText.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.white : Color.clear)
                    .shadow(color: isSelected ? Color.black.opacity(0.08) : .clear, radius: 2, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Skeleton Placeholder Views

struct SkeletonBlock: View {
    var height: CGFloat = 16
    var width: CGFloat? = nil
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(hex: "E0E0E0"))
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.4), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.4)
                    .offset(x: shimmerOffset * geo.size.width)
                }
                .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerOffset = 1.4
                }
            }
    }
}

struct TimelineSkeletonView: View {
    private let borderColor = Color(hex: "E0E0E0")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonBlock(height: 14, width: 120)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(borderColor)
                            .frame(width: 8, height: 8)
                            .padding(.top, 4)

                        VStack(alignment: .leading, spacing: 6) {
                            SkeletonBlock(height: 10, width: 80)
                            SkeletonBlock(height: 14)
                            SkeletonBlock(height: 14, width: 200)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
        }
    }
}

struct WhatToWatchSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonBlock(height: 14, width: 110)
            SkeletonBlock(height: 14)
            SkeletonBlock(height: 14)
            SkeletonBlock(height: 14, width: 180)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppTheme.orangeSoft.opacity(0.5))
        )
    }
}

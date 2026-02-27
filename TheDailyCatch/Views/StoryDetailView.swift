import SwiftUI

struct StoryDetailView: View {
    let stories: [Story]
    let initialIndex: Int
    let onClose: () -> Void
    let onStoryViewed: (Story) -> Void

    @State private var currentIndex: Int
    @State private var isDeepMode = false
    @State private var dragOffset: CGFloat = 0
    @State private var showCaughtUp = false

    private let bgColor = Color(hex: "D6D6D6")
    private let darkText = Color(hex: "2A2A2A")

    init(stories: [Story], initialIndex: Int, onClose: @escaping () -> Void, onStoryViewed: @escaping (Story) -> Void) {
        self.stories = stories
        self.initialIndex = initialIndex
        self.onClose = onClose
        self.onStoryViewed = onStoryViewed
        self._currentIndex = State(initialValue: initialIndex)
    }

    private var story: Story { stories[currentIndex] }

    var body: some View {
        ZStack(alignment: .top) {
            if showCaughtUp {
                caughtUpView
                    .transition(.move(edge: .trailing))
            } else {
                bgColor.ignoresSafeArea()

                Image("NewsPageBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.top, 46)

                VStack(spacing: 0) {
                    topBar
                    storyContent
                        .offset(x: dragOffset)
                }

                VStack {
                    Spacer()
                    pageIndicator
                        .padding(.bottom, 40)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onChanged { value in
                    // Only track horizontal drags
                    if abs(value.translation.width) > abs(value.translation.height) {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height

                    if abs(horizontal) > abs(vertical) && abs(horizontal) > 80 {
                        // Horizontal swipe
                        if horizontal < 0 && currentIndex < stories.count - 1 {
                            // Swipe left → next story
                            withAnimation(.easeInOut(duration: 0.25)) {
                                dragOffset = -UIScreen.main.bounds.width
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                currentIndex += 1
                                onStoryViewed(stories[currentIndex])
                                dragOffset = UIScreen.main.bounds.width
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    dragOffset = 0
                                }
                            }
                        } else if horizontal < 0 && currentIndex == stories.count - 1 {
                            // Swipe left on last story → show caught up
                            withAnimation(.easeInOut(duration: 0.25)) {
                                dragOffset = -UIScreen.main.bounds.width
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showCaughtUp = true
                                }
                                dragOffset = 0
                            }
                        } else if horizontal > 0 && showCaughtUp {
                            // Swipe right from caught up → back to last story
                            dragOffset = 0
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showCaughtUp = false
                            }
                        } else if horizontal > 0 && currentIndex > 0 {
                            // Swipe right → previous story
                            withAnimation(.easeInOut(duration: 0.25)) {
                                dragOffset = UIScreen.main.bounds.width
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                currentIndex -= 1
                                onStoryViewed(stories[currentIndex])
                                dragOffset = -UIScreen.main.bounds.width
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    dragOffset = 0
                                }
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                dragOffset = 0
                            }
                        }
                    } else if vertical > 100 {
                        // Swipe down → close
                        onClose()
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }

    // MARK: - Helpers

    private func cleanText(_ text: String) -> String {
        var cleaned = text
        let pattern = "\\[\\d+\\]"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            cleaned = regex.stringByReplacingMatches(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned), withTemplate: "")
        }
        cleaned = cleaned.replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
        return cleaned
    }

    private func truncateToSentences(_ text: String, max: Int) -> String {
        let cleaned = cleanText(text)
        var sentences: [String] = []
        cleaned.enumerateSubstrings(in: cleaned.startIndex..., options: .bySentences) { substring, _, _, stop in
            if let s = substring {
                sentences.append(s)
            }
            if sentences.count >= max {
                stop = true
            }
        }
        return sentences.joined().trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Story counter pill
            Text("\(currentIndex + 1)/\(stories.count)")
                .font(AppTheme.mono(12, weight: .bold))
                .foregroundStyle(darkText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "CEDCE9"))
                .clipShape(Capsule())

            Spacer()

            // QUICK | DEEP toggle
            HStack(spacing: 0) {
                Text("QUICK")
                    .font(AppTheme.mono(15.4, weight: .bold))
                    .foregroundStyle(isDeepMode ? darkText.opacity(0.4) : darkText)
                    .underline(!isDeepMode)
                    .onTapGesture { isDeepMode = false }

                Text(" | ")
                    .font(AppTheme.mono(15.4, weight: .bold))
                    .foregroundStyle(darkText.opacity(0.4))

                Text("DEEP")
                    .font(AppTheme.mono(15.4, weight: .bold))
                    .foregroundStyle(isDeepMode ? darkText : darkText.opacity(0.4))
                    .underline(isDeepMode)
                    .onTapGesture { isDeepMode = true }
            }

            Spacer()

            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15.4, weight: .bold))
                    .foregroundStyle(darkText)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 58)
        .padding(.bottom, 8)
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<stories.count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? darkText : darkText.opacity(0.25))
                    .frame(width: 5, height: 5)
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Story Content

    private var storyContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Category
                Text(story.category.uppercased())
                    .font(AppTheme.mono(11, weight: .bold))
                    .foregroundStyle(Color(hex: story.categoryColor))
                    .padding(.bottom, -12)

                // Headline
                Text(story.headline.uppercased())
                    .font(AppTheme.headline(34, weight: .bold))
                    .foregroundStyle(darkText)
                    .lineSpacing(2)

                // What happened
                VStack(alignment: .leading, spacing: 8) {
                    Text("What happened")
                        .font(.custom("SpaceGrotesk-Light", size: 13).weight(.bold))
                        .foregroundStyle(darkText)

                    Text(isDeepMode ? cleanText(story.hook) : truncateToSentences(story.hook, max: 2))
                        .font(AppTheme.body(14))
                        .foregroundStyle(darkText.opacity(0.8))
                        .lineSpacing(5)
                }

                // Why it matters now
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why it matters now")
                        .font(.custom("SpaceGrotesk-Light", size: 13).weight(.bold))
                        .foregroundStyle(darkText)

                    Text(isDeepMode ? cleanText(story.context) : truncateToSentences(story.context, max: 2))
                        .font(AppTheme.body(14))
                        .foregroundStyle(darkText.opacity(0.8))
                        .lineSpacing(5)
                }

                // Deep dive (only in deep mode)
                if isDeepMode {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deep dive")
                            .font(.custom("SpaceGrotesk-Light", size: 13).weight(.bold))
                            .foregroundStyle(darkText)

                        Text(cleanText(story.hook) + "\n\n" + cleanText(story.context))
                            .font(AppTheme.body(14))
                            .foregroundStyle(darkText.opacity(0.8))
                            .lineSpacing(5)
                    }
                }

                // How this affect you card
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How this affect you")
                            .font(.custom("SpaceGrotesk-Light", size: 13).weight(.bold))
                            .foregroundStyle(Color(hex: "375BCD"))

                        Text(cleanText(story.soWhat))
                            .font(AppTheme.body(14))
                            .foregroundStyle(darkText.opacity(0.8))
                            .lineSpacing(5)
                    }
                    .padding(16)
                    .padding(.trailing, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "F2F2F2"))
                    )
                    .compositingGroup()
                    .shadow(color: Color.black.opacity(0.25), radius: 2, x: 2, y: 2)

                    Image("MetalClip")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 96)
                        .offset(x: 6, y: -34)
                }

                // Sources
                HStack(spacing: 8) {
                    Image("PaperClamp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)

                    Text(story.sources.joined(separator: " · ") + " — as of \(story.timestamp)")
                        .font(AppTheme.body(11))
                        .foregroundStyle(AppTheme.textMidGrey)
                }
                .padding(.top, 4)

                Spacer(minLength: 80)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .id(currentIndex)
    }

    // MARK: - Caught Up View

    private var caughtUpView: some View {
        ZStack {
            Color(hex: "E8E7E5")
                .ignoresSafeArea()

            // Background image
            Image("CaughtUpBackground")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Paper clamp + tape sticker at top right
                ZStack(alignment: .topTrailing) {
                    // Tape sticker
                    Image("WellDoneCaughtUpTape")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 110)
                        .rotationEffect(.degrees(2), anchor: .trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 34)

                    // Paper clamp on top
                    Image("PaperClamp")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .padding(.trailing, 30)
                        .offset(y: -30)
                }

                Spacer()

                // Coffee icon
                Image("CaughtUpIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)

                // Headline
                Text("YOU ARE ALL\nCAUGHT UP.")
                    .font(AppTheme.headline(34, weight: .black))
                    .foregroundStyle(darkText)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("That's your catch for today.\nGo live your life. See you tomorrow:)")
                    .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                    .foregroundStyle(darkText.opacity(0.6))
                    .multilineTextAlignment(.center)

                // Next catch
                Text("Next Catch Tomorrow, 7:00 AM ET")
                    .font(.custom("SpaceGrotesk-Light", size: 12).weight(.medium))
                    .foregroundStyle(Color(hex: "375BCD"))

                // Okay got it button
                Button(action: onClose) {
                    Text("OKAY, GOT IT")
                        .font(AppTheme.mono(14, weight: .bold))
                        .foregroundStyle(darkText)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color(hex: "CEDCE9"))
                        .clipShape(Rectangle())
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 2, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                Spacer()
                Spacer()
            }
        }
    }
}

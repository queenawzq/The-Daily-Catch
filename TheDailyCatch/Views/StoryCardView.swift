import SwiftUI

struct StoryCardView: View {
    let story: Story
    let progress: String

    var body: some View {
        ZStack {
            story.gradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text(progress)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())

                        Spacer()
                    }

                    Text(story.emoji)
                        .font(.system(size: 48))

                    Text(story.headline)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(story.summary)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineSpacing(4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why should I care?")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(story.whyItMatters)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if !story.source.isEmpty {
                        HStack {
                            Image(systemName: "link")
                                .font(.caption)
                            Text(story.source)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer(minLength: 60)
                }
                .padding(24)
            }
        }
    }
}

import SwiftUI

struct StoryCardView: View {
    let story: Story
    let storyNumber: Int
    let isRead: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                // Category tag
                Text(story.category.uppercased())
                    .font(AppTheme.mono(11, weight: .bold))
                    .foregroundStyle(Color(hex: story.categoryColor))

                // Headline
                Text(story.headline.uppercased())
                    .font(AppTheme.headline(20, weight: .bold))
                    .foregroundStyle(AppTheme.textDark)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                // Hook text
                Text(story.hook)
                    .font(.custom("SpaceGrotesk-Light", size: 13).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.5))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: Color.black.opacity(0.25), radius: 4, x: 2, y: 2)
        }
        .buttonStyle(.plain)
    }
}

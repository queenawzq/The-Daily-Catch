import SwiftUI
import UIKit

/// UITextView-backed selectable text that exposes the full system edit menu
/// (Look Up, Translate, Share, Copy). SwiftUI's `Text` + `.textSelection(.enabled)`
/// only shows Copy/Share, so this wrapper is needed to enable dictionary lookup.
///
/// `linkTextAttributes` styles `.link` ranges (UITextView would otherwise render
/// them in system blue). `onLinkTap` is invoked when an embedded link is tapped —
/// return true to consume the tap and suppress default URL handling.
struct SelectableText: UIViewRepresentable {
    let attributedText: NSAttributedString
    var linkTextAttributes: [NSAttributedString.Key: Any]? = nil
    var onLinkTap: ((URL) -> Bool)? = nil

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = true
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainer.widthTracksTextView = true
        tv.textContainer.lineBreakMode = .byWordWrapping
        tv.dataDetectorTypes = []
        tv.adjustsFontForContentSizeCategory = false
        tv.delegate = context.coordinator
        // Let SwiftUI constrain width so text wraps; pin height to laid-out content.
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tv.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tv.setContentCompressionResistancePriority(.required, for: .vertical)
        tv.setContentHuggingPriority(.required, for: .vertical)
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if !(uiView.attributedText?.isEqual(to: attributedText) ?? false) {
            uiView.attributedText = attributedText
            uiView.invalidateIntrinsicContentSize()
        }
        if let linkTextAttributes {
            uiView.linkTextAttributes = linkTextAttributes
        }
        context.coordinator.onLinkTap = onLinkTap
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width.isFinite, width > 0 else { return nil }
        let fitted = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: ceil(fitted.height))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onLinkTap: onLinkTap)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var onLinkTap: ((URL) -> Bool)?

        init(onLinkTap: ((URL) -> Bool)?) {
            self.onLinkTap = onLinkTap
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            guard let onLinkTap else { return true }
            return !onLinkTap(URL)
        }
    }
}

extension NSAttributedString {
    /// Body-style attributed string matching the SwiftUI styling used across story
    /// body and deep dive content: SpaceGrotesk-Light 15.5 medium, dark text 0.65 alpha,
    /// 5pt line spacing.
    static func storyBody(_ text: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let descriptor = UIFontDescriptor(name: "SpaceGrotesk-Light", size: 15.5)
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium.rawValue]
            ])
        let font = UIFont(descriptor: descriptor, size: 15.5)
        let color = UIColor(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0, alpha: 0.65)
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ])
    }
}

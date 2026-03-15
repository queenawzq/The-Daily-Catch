import Foundation

/// Strips citation markers like [1], [3] and stray brackets from text,
/// and fixes mismatched smart quotes.
func cleanText(_ text: String) -> String {
    var cleaned = text
    let pattern = "\\[\\d+\\]"
    if let regex = try? NSRegularExpression(pattern: pattern) {
        cleaned = regex.stringByReplacingMatches(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned), withTemplate: "")
    }
    cleaned = cleaned.replacingOccurrences(of: "[", with: "")
        .replacingOccurrences(of: "]", with: "")

    cleaned = fixQuotes(cleaned)

    return cleaned
}

/// Normalizes all single and double quotes to properly paired smart quotes.
/// Handles: ASCII quotes (' "), curly quotes used incorrectly (\u{2019}X\u{2019}),
/// backtick-style quotes, and mixed quote pairs.
private func fixQuotes(_ text: String) -> String {
    var chars = Array(text)
    let count = chars.count

    // Track whether we're inside a quoted span
    var inSingleQuote = false
    var inDoubleQuote = false

    for i in 0..<count {
        let c = chars[i]

        // --- Single quotes: ', ', ', ` ---
        if c == "\u{2018}" || c == "\u{2019}" || c == "`" {
            if !inSingleQuote {
                // Check if this looks like an opener: followed by a letter/digit
                let next = i + 1 < count ? chars[i + 1] : Character(" ")
                if next.isLetter || next.isNumber {
                    chars[i] = "\u{2018}" // left single quote
                    inSingleQuote = true
                } else {
                    chars[i] = "\u{2019}" // closing/apostrophe
                }
            } else {
                // We're inside a single-quoted span — this is the closer
                chars[i] = "\u{2019}" // right single quote
                inSingleQuote = false
            }
        }

        // Handle ASCII single quote used as smart quote or apostrophe
        if c == "'" {
            let prev = i > 0 ? chars[i - 1] : Character(" ")
            let next = i + 1 < count ? chars[i + 1] : Character(" ")

            if !inSingleQuote && (prev == " " || prev == "\n" || prev == "\t" || prev == "(" || prev == "\u{2014}" || prev == "-" || i == 0) && (next.isLetter || next.isNumber) {
                // Opener
                chars[i] = "\u{2018}"
                inSingleQuote = true
            } else if inSingleQuote && (next == " " || next == "." || next == "," || next == ";" || next == ":" || next == "!" || next == "?" || next == "\n" || i == count - 1) {
                // Closer
                chars[i] = "\u{2019}"
                inSingleQuote = false
            } else {
                // Apostrophe (e.g. don't, it's, xAI's)
                chars[i] = "\u{2019}"
            }
        }

        // --- Double quotes: ", \u{201C}, \u{201D} ---
        if c == "\u{201C}" || c == "\u{201D}" {
            if !inDoubleQuote {
                let next = i + 1 < count ? chars[i + 1] : Character(" ")
                if next.isLetter || next.isNumber {
                    chars[i] = "\u{201C}" // left double quote
                    inDoubleQuote = true
                } else {
                    chars[i] = "\u{201D}" // right double quote
                }
            } else {
                chars[i] = "\u{201D}"
                inDoubleQuote = false
            }
        }

        if c == "\"" {
            let prev = i > 0 ? chars[i - 1] : Character(" ")
            let next = i + 1 < count ? chars[i + 1] : Character(" ")

            if !inDoubleQuote && (prev == " " || prev == "\n" || prev == "\t" || prev == "(" || i == 0) && (next.isLetter || next.isNumber) {
                chars[i] = "\u{201C}"
                inDoubleQuote = true
            } else {
                chars[i] = "\u{201D}"
                if inDoubleQuote { inDoubleQuote = false }
            }
        }
    }

    return String(chars)
}

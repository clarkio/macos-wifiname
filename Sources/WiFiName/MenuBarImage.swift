import AppKit

/// Draws the two-line menu bar label (name on top, speeds below) as a template
/// image. `MenuBarExtra` labels can't reliably show two lines of small text, but
/// an image can, and a template image follows light/dark menu bar automatically.
enum MenuBarImage {
    private static let barHeight: CGFloat = 22
    private static let lineHeight: CGFloat = 11   // two lines must fit inside barHeight
    private static let topFont = NSFont.systemFont(ofSize: 9.5, weight: .semibold)
    private static let bottomFont = NSFont.monospacedDigitSystemFont(ofSize: 9, weight: .regular)

    /// Reserve room for a typical speed line so the item doesn't resize every second.
    private static let minimumWidth: CGFloat = {
        let sample = NSAttributedString(string: "↓888KB/s ↑888KB/s", attributes: [.font: bottomFont])
        return ceil(sample.size().width)
    }()

    static func make(top: String, bottom: String) -> NSImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byClipping

        let topText = NSAttributedString(string: top, attributes: [
            .font: topFont, .foregroundColor: NSColor.black, .paragraphStyle: paragraph,
        ])
        let bottomText = NSAttributedString(string: bottom, attributes: [
            .font: bottomFont, .foregroundColor: NSColor.black, .paragraphStyle: paragraph,
        ])

        let width = max(ceil(max(topText.size().width, bottomText.size().width)), minimumWidth)

        let image = NSImage(size: NSSize(width: width, height: barHeight), flipped: false) { _ in
            // Fixed rectangles (origin is bottom-left), one per line, so neither line can be pushed out of view.
            bottomText.draw(in: NSRect(x: 0, y: 0, width: width, height: lineHeight))
            topText.draw(in: NSRect(x: 0, y: lineHeight, width: width, height: lineHeight))
            return true
        }
        image.isTemplate = true
        return image
    }
}

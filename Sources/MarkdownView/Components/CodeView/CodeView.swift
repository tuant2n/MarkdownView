//
//  Created by ktiays on 2025/1/22.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import Litext
import UIKit

final class CodeView: UIView {
    var theme: MarkdownTheme = .default {
        didSet {
            languageLabel.font = theme.fonts.code
            performHighlight(with: content)
        }
    }

    var language: String = "" {
        didSet {
            languageLabel.text = language
        }
    }

    var previewAction: ((String?, NSAttributedString) -> Void)? {
        didSet {
            setNeedsLayout()
        }
    }

    private var _content: String = ""
    var content: String {
        set {
            let oldValue = _content
            _content = newValue

            if !shouldPreserveHighlight(oldValue: oldValue, newValue: newValue) {
                calculatedAttributes.removeAll()
            }
            updateHighlightedContent()
            performHighlight(with: newValue)
        }
        get { _content }
    }

    var calculatedAttributes: [NSRange: UIColor] = [:]
    private let callerIdentifier = UUID()

    lazy var barView: UIView = .init()
    lazy var scrollView: UIScrollView = .init()
    lazy var languageLabel: UILabel = .init()
    lazy var textView: LTXLabel = .init()
    lazy var copyButton: UIButton = .init()
    lazy var previewButton: UIButton = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func intrinsicHeight(for content: String, theme: MarkdownTheme = .default) -> CGFloat {
        CodeViewConfiguration.intrinsicHeight(for: content, theme: theme)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = languageLabel.intrinsicContentSize
        let barHeight = labelSize.height + CodeViewConfiguration.barPadding * 2
        let textSize = textView.intrinsicContentSize
        let supposedHeight = Self.intrinsicHeight(for: content, theme: theme)

        return CGSize(
            width: max(
                labelSize.width + CodeViewConfiguration.barPadding * 2,
                textSize.width + CodeViewConfiguration.codePadding * 2
            ),
            height: max(
                barHeight + textSize.height + CodeViewConfiguration.codePadding * 2,
                supposedHeight
            )
        )
    }

    @objc func handleCopy(_: UIButton) {
        UIPasteboard.general.string = content
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    @objc func handlePreview(_: UIButton) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        previewAction?(language, textView.attributedText)
    }

    private func shouldPreserveHighlight(oldValue: String?, newValue: String?) -> Bool {
        guard let oldValue, !oldValue.isEmpty,
              let newValue, !newValue.isEmpty
        else { return false }
        return newValue.hasPrefix(oldValue)
    }

    private func performHighlight(with code: String) {
        CodeHighlighter.shared.submitHighlightRequest(
            content: code,
            language: language,
            callerIdentifier: callerIdentifier,
            theme: theme
        ) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.handleHighlightResult(result)
            }
        }
    }

    private func handleHighlightResult(_ result: HighlightResult) {
        switch result {
        case let .success(attributedString):
            calculatedAttributes = extractColorAttributes(from: attributedString)
            updateHighlightedContent()

        case .cancelled:
            break

        case let .error(errorMessage):
            print("[-] code highlighting error: \(errorMessage)")
            calculatedAttributes.removeAll()
            updateHighlightedContent()
        }
    }

    private func extractColorAttributes(from attributedString: NSAttributedString) -> [NSRange: UIColor] {
        var attributes: [NSRange: UIColor] = [:]
        let nsString = attributedString.string as NSString

        attributedString.enumerateAttribute(
            .foregroundColor,
            in: NSRange(location: 0, length: attributedString.length)
        ) { value, range, _ in
            if range.length == 1 {
                if let char = nsString.substring(with: range).first, char.isWhitespace {
                    return
                }
            }

            guard let color = value as? UIColor else { return }
            attributes[range] = color
        }

        return attributes
    }

    private func updateHighlightedContent() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CodeViewConfiguration.codeLineSpacing

        let plainTextColor = theme.colors.code
        let attributedContent: NSMutableAttributedString = .init(
            string: content,
            attributes: [
                .font: theme.fonts.code,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: plainTextColor,
            ]
        )

        let length = attributedContent.length
        var hasAppliedHighlight = false

        for (range, color) in calculatedAttributes {
            guard range.location >= 0, range.upperBound <= length else { continue }
            guard color != plainTextColor else { continue }
            let substring = attributedContent.attributedSubstring(from: range).string
            guard !substring.allSatisfy(\.isWhitespace) else { continue }
            attributedContent.addAttributes([
                .foregroundColor: color,
            ], range: range)
            hasAppliedHighlight = true
        }
        if hasAppliedHighlight || textView.attributedText.string != content {
            textView.attributedText = attributedContent
        }
    }
}

extension CodeView: LTXAttributeStringRepresentable {
    func attributedStringRepresentation() -> NSAttributedString {
        textView.attributedText
    }
}

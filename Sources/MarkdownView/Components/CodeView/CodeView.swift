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
            guard _content != newValue else { return }
            let oldValue = _content
            _content = newValue

            if newValue.isEmpty || !shouldPreserveHighlight(oldValue: oldValue, newValue: newValue) {
                calculatedAttributes.removeAll()
            } else {
                updateHighlightedContent()
            }
            if !newValue.isEmpty {
                performHighlight(with: newValue)
            }
        }
        get { _content }
    }

    var calculatedAttributes: [NSRange: UIColor] = [:] {
        didSet { updateHighlightedContent() }
    }

    private let callerIdentifier = UUID()
    private var currentTaskIdentifier: UUID?

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
        guard var oldValue, !oldValue.isEmpty,
              let newValue, !newValue.isEmpty
        else { return false }

        // the view might have ``` in the end which means
        // these characters are revoked once codeblock is completed
        // so ignore them on comparison
        while oldValue.hasSuffix("`") {
            oldValue.removeLast()
        }
        oldValue = oldValue.trimmingCharacters(in: .whitespacesAndNewlines)

        return newValue.hasPrefix(oldValue)
    }

    private func performHighlight(with code: String) {
        // cancel the previous task if it exists
        if let currentTask = currentTaskIdentifier {
            CodeHighlighter.current.cancelHighlight(taskIdentifier: currentTask)
        }

        let taskIdentifier = UUID()
        currentTaskIdentifier = taskIdentifier

        let request = CodeHighlighter.HighlightRequest(
            taskIdentifier: taskIdentifier,
            callerIdentifier: callerIdentifier,
            language: language,
            content: code,
            theme: theme
        )

        CodeHighlighter.current.beginHighlight(request: request) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.handleHighlightResult(result)
            }
        }
    }

    private func handleHighlightResult(_ result: CodeHighlighter.HighlightResult) {
        switch result {
        case let .cache(task, map):
            guard task == currentTaskIdentifier else { return }
            calculatedAttributes = map

        case let .highlighted(task, map):
            guard task == currentTaskIdentifier else { return }
            calculatedAttributes = map
            currentTaskIdentifier = nil
        }
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

        for (range, color) in calculatedAttributes {
            guard range.location >= 0, range.upperBound <= length else { continue }
            guard color != plainTextColor else { continue }
            attributedContent.addAttributes([.foregroundColor: color], range: range)
        }
        textView.attributedText = attributedContent
    }
}

extension CodeView: LTXAttributeStringRepresentable {
    func attributedStringRepresentation() -> NSAttributedString {
        textView.attributedText
    }
}

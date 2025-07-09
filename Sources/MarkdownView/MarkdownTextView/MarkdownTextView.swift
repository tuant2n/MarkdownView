//
//  Created by ktiays on 2025/1/20.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import CoreText
import Litext
import MarkdownParser
import UIKit

public final class MarkdownTextView: UIView {
    let viewProvider: ReusableViewProvider

    public private(set) var document: PreprocessContent = .init()

    public var linkHandler: ((LinkPayload, NSRange, CGPoint) -> Void)?
    public var codePreviewHandler: ((String?, NSAttributedString) -> Void)?

    private var attributedText: NSAttributedString? {
        get { textView.attributedText }
        set { textView.attributedText = newValue ?? .init() }
    }

    private lazy var textView: LTXLabel = .init()
    public var theme: MarkdownTheme = .default {
        didSet { setMarkdown(document) } // update it
    }
    
    private var contextViews: [UIView] = []
    
    public init() {
        viewProvider = .init()
        super.init(frame: .zero)
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.attributedText = attributedText ?? .init()
        textView.delegate = self
        addSubview(textView)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        textView.preferredMaxLayoutWidth = bounds.width
        textView.frame = bounds
    }

    public func boundingSize(for width: CGFloat) -> CGSize {
        textView.preferredMaxLayoutWidth = width
        return textView.intrinsicContentSize
    }

    public func setMarkdown(_ content: PreprocessContent) {
        assert(Thread.isMainThread)
        document = content
        // due to a bug in model gemini-flash
        // there might be a large of unknown empty whitespace inside the table
        // thus we hereby call the autoreleasepool to avoid large memory consumption
        autoreleasepool { self.updateTextExecute() }
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    public func reset() {
        assert(Thread.isMainThread)
        setMarkdown(.init())
        contextViews.forEach { view in
            if let view = view as? CodeView {
                viewProvider.releaseCodeView(view)
                return
            }
            if let view = view as? TableView {
                viewProvider.releaseTableView(view)
                return
            }
            assertionFailure()
        }
        contextViews.removeAll()
    }
}

extension MarkdownTextView {
    private func updateTextExecute() {
        let artifacts = TextBuilder.build(view: self)
        contextViews.forEach { view in
            if let view = view as? CodeView {
                viewProvider.releaseCodeView(view)
                return
            }
            if let view = view as? TableView {
                viewProvider.releaseTableView(view)
                return
            }
            assertionFailure()
        }
        contextViews.removeAll()
        attributedText = artifacts.document
        contextViews = artifacts.subviews
    }
}

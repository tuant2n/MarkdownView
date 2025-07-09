//
//  Created by ktiays on 2025/1/20.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import Combine
import CoreText
import Litext
import MarkdownParser
import UIKit

public final class MarkdownTextView: UIView {
    public var linkHandler: ((LinkPayload, NSRange, CGPoint) -> Void)?
    public var codePreviewHandler: ((String?, NSAttributedString) -> Void)?

    public internal(set) var document: PreprocessContent = .init()
    public let textView: LTXLabel = .init()
    public var theme: MarkdownTheme = .default {
        didSet { setMarkdown(document, updateNow: true) } // update it
    }

    public internal(set) weak var trackedScrollView: UIScrollView? // for selection updating

    var contextViews: [UIView] = []
    var cancellables = Set<AnyCancellable>()
    let contentSubject = CurrentValueSubject<PreprocessContent, Never>(.init())
    public var throttleInterval: TimeInterval? = 1 / 20 { // x fps
        didSet { setupCombine() }
    }

    let viewProvider: ReusableViewProvider

    public init(viewProvider: ReusableViewProvider = .init()) {
        self.viewProvider = viewProvider
        super.init(frame: .zero)
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.delegate = self
        addSubview(textView)
        setupCombine()
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

    public func setMarkdown(_ content: PreprocessContent, updateNow: Bool) {
        if updateNow {
            resetCombine()
            contentSubject.send(content)
            setupCombine()
        } else {
            contentSubject.send(content)
        }
    }

    public func reset() {
        assert(Thread.isMainThread)
        setMarkdown(.init(), updateNow: false)
    }
}

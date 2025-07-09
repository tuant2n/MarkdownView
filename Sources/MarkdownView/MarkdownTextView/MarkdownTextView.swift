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
    public private(set) var document: PreprocessContent = .init()

    public var linkHandler: ((LinkPayload, NSRange, CGPoint) -> Void)?
    public var codePreviewHandler: ((String?, NSAttributedString) -> Void)?

    lazy var textView: LTXLabel = .init()
    public var theme: MarkdownTheme = .default {
        didSet { setMarkdown(document) } // update it
    }

    var contextViews: [UIView] = []
    var cancellables = Set<AnyCancellable>()
    let contentSubject = CurrentValueSubject<PreprocessContent, Never>(.init())
    public var throttleInterval: TimeInterval? = 1 / 30 { // x fps
        didSet { setupCombine() }
    }

    let viewProvider: ReusableViewProvider = .init()

    public init() {
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

    private func setupCombine() {
        if let throttleInterval {
            contentSubject
                .throttle(for: .seconds(throttleInterval), scheduler: DispatchQueue.main, latest: true)
                .sink { [weak self] content in self?.use(content) }
                .store(in: &cancellables)
        } else {
            contentSubject
                .sink { [weak self] content in self?.use(content) }
                .store(in: &cancellables)
        }
    }

    public func boundingSize(for width: CGFloat) -> CGSize {
        textView.preferredMaxLayoutWidth = width
        return textView.intrinsicContentSize
    }

    public func setMarkdown(_ content: PreprocessContent) {
        if Thread.isMainThread {
            contentSubject.send(content)
        } else {
            DispatchQueue.main.asyncAndWait {
                self.setMarkdown(content)
            }
        }
    }

    private func use(_ content: PreprocessContent) {
        assert(Thread.isMainThread)
        document = content
        // due to a bug in model gemini-flash
        // there might be a large of unknown empty whitespace inside the table
        // thus we hereby call the autoreleasepool to avoid large memory consumption
        autoreleasepool { updateTextExecute() }
    }

    public func reset() {
        assert(Thread.isMainThread)
        contentSubject.send(.init())
    }
}

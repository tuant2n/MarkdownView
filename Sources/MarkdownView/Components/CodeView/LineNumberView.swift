//
//  Created by ktiays on 2025/1/22.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import UIKit

final class LineNumberView: UIView {
    var lineHeight: CGFloat = 20 {
        didSet { setNeedsDisplay() }
    }

    var lineCount: Int = 1 {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }

    var font: UIFont = .monospacedSystemFont(ofSize: 12, weight: .regular) {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }

    var textColor: UIColor = .secondaryLabel {
        didSet { setNeedsDisplay() }
    }

    var padding: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    override var intrinsicContentSize: CGSize {
        let maxLineNumber = max(lineCount, 1)
        let numberString = "\(maxLineNumber)"
        let textSize = numberString.size(withAttributes: [.font: font])

        return CGSize(
            width: textSize.width + padding.left + padding.right,
            height: CGFloat(lineCount) * lineHeight + padding.top + padding.bottom
        )
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
        ]
        let startY = padding.top

        for lineNumber in 1 ... lineCount {
            let numberString = "\(lineNumber)"
            let textSize = numberString.size(withAttributes: textAttributes)

            let x = bounds.width - padding.right - textSize.width
            let y = startY + CGFloat(lineNumber - 1) * lineHeight

            let textRect = CGRect(
                x: x,
                y: y,
                width: textSize.width,
                height: textSize.height
            )

            numberString.draw(in: textRect, withAttributes: textAttributes)
        }
    }

    func configure(lineCount: Int, lineHeight: CGFloat, font: UIFont, textColor: UIColor) {
        self.lineCount = lineCount
        self.lineHeight = lineHeight
        self.font = font
        self.textColor = textColor
    }

    func updateForContent(_ content: String) {
        let lines = content.components(separatedBy: .newlines)
        lineCount = max(lines.count, 1)
    }
}

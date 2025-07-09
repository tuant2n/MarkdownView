//
//  TextBuilder+Do.swift
//  MarkdownView
//
//  Created by 秋星桥 on 7/9/25.
//

import CoreText
import Foundation
import UIKit

private let kImageConfiguration = UIImage.SymbolConfiguration(scale: .small)
private let kCheckedBoxImage: UIImage = .init(systemName: "checkmark.square.fill", withConfiguration: kImageConfiguration) ?? .init()
private let kUncheckedBoxImage = UIImage(systemName: "square", withConfiguration: kImageConfiguration) ?? .init()

extension TextBuilder {
    @inline(__always)
    static func lineBoundingBox(_ line: CTLine, lineOrigin: CGPoint) -> CGRect {
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, nil)
        return .init(x: lineOrigin.x, y: lineOrigin.y - descent, width: width, height: ascent + descent)
    }

    static func build(view: MarkdownTextView) -> BuildResult {
        let context: MarkdownTextView.PreprocessContent = view.document
        let theme: MarkdownTheme = view.theme
        let viewProvider: ReusableViewProvider = view.viewProvider

        return TextBuilder(nodes: context.blocks, context: context, viewProvider: viewProvider)
            .withTheme(theme)
            .withBulletDrawing { context, line, lineOrigin, depth in
                let radius: CGFloat = 3
                let boundingBox = lineBoundingBox(line, lineOrigin: lineOrigin)
                context.setStrokeColor(theme.colors.body.cgColor)
                context.setFillColor(theme.colors.body.cgColor)
                let rect = CGRect(
                    x: boundingBox.minX - 16,
                    y: boundingBox.midY - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                if depth == 0 {
                    context.fillEllipse(in: rect)
                } else if depth == 1 {
                    context.strokeEllipse(in: rect)
                } else {
                    context.fill(rect)
                }
            }
            .withNumberedDrawing { context, line, lineOrigin, index, indent, size in
                var text = "\(index)."
                while text.count < size + 1 {
                    text = " " + text
                }
                let string = NSAttributedString(string: text, attributes: [
                    .font: theme.fonts.codeInline,
                    .foregroundColor: theme.colors.body,
                ])
                let rect = lineBoundingBox(line, lineOrigin: lineOrigin).offsetBy(dx: -indent, dy: 0)
                let path = CGPath(rect: rect, transform: nil)
                let framesetter = CTFramesetterCreateWithAttributedString(string)
                let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), path, nil)
                CTFrameDraw(frame, context)
            }
            .withCheckboxDrawing { context, line, lineOrigin, isChecked in
                let rect = lineBoundingBox(line, lineOrigin: lineOrigin).offsetBy(dx: -20, dy: 0)
                let image = if isChecked { kCheckedBoxImage } else { kUncheckedBoxImage }
                guard let cgImage = image.cgImage else { return }
                let imageSize = image.size
                let targetRect: CGRect = .init(
                    x: rect.minX,
                    y: rect.midY - imageSize.height / 2,
                    width: imageSize.width,
                    height: imageSize.height
                )
                context.clip(to: targetRect, mask: cgImage)
                context.setFillColor(theme.colors.body.withAlphaComponent(0.24).cgColor)
                context.fill(targetRect)
            }
            .withThematicBreakDrawing { [weak view] context, line, lineOrigin in
                guard let view else { return }
                let boundingBox = lineBoundingBox(line, lineOrigin: lineOrigin)

                context.setLineWidth(1)
                context.setStrokeColor(UIColor.label.withAlphaComponent(0.1).cgColor)
                context.move(to: .init(x: boundingBox.minX, y: boundingBox.midY))
                context.addLine(to: .init(x: boundingBox.minX + view.bounds.width, y: boundingBox.midY))
                context.strokePath()
            }
            .withCodeDrawing { [weak view] _, line, lineOrigin in
                guard let view else { return }
                guard let firstRun = line.glyphRuns().first else { return }
                let attributes = firstRun.attributes
                guard let codeView = attributes[.contextView] as? CodeView else {
                    assertionFailure()
                    return
                }

                if codeView.superview != view { view.addSubview(codeView) }
                let intrinsicContentSize = codeView.intrinsicContentSize
                let lineBoundingBox = lineBoundingBox(line, lineOrigin: lineOrigin)
                codeView.frame = .init(
                    origin: .init(x: lineOrigin.x, y: view.bounds.height - lineBoundingBox.maxY),
                    size: .init(width: view.bounds.width, height: intrinsicContentSize.height)
                )
                codeView.previewAction = view.codePreviewHandler
            }
            .withTableDrawing { [weak view] _, line, lineOrigin in
                guard let view else { return }
                guard let firstRun = line.glyphRuns().first else { return }
                let attributes = firstRun.attributes
                guard let tableView = attributes[.contextView] as? TableView else {
                    assertionFailure()
                    return
                }

                if tableView.superview != view { view.addSubview(tableView) }
                let lineBoundingBox = lineBoundingBox(line, lineOrigin: lineOrigin)
                let intrinsicContentSize = tableView.intrinsicContentSize
                tableView.frame = .init(
                    x: lineOrigin.x,
                    y: view.bounds.height - lineBoundingBox.maxY,
                    width: view.bounds.width,
                    height: intrinsicContentSize.height
                )
            }
            .build()
    }
}

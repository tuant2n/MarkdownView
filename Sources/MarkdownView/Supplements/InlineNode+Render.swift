//
//  InlineNode+Render.swift
//  MarkdownView
//
//  Created by 秋星桥 on 2025/1/3.
//

import Foundation
import Litext
import MarkdownParser
import SwiftMath
import UIKit

extension [MarkdownInlineNode] {
    func render(theme: MarkdownTheme, renderedContext: RenderContext, viewProvider: DrawingViewProvider) -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        for node in self {
            result.append(node.render(theme: theme, renderedContext: renderedContext, viewProvider: viewProvider))
        }
        return result
    }
}

extension MarkdownInlineNode {
    func placeImage(theme: MarkdownTheme, image: UIImage, representText: String, viewProvider: DrawingViewProvider) -> NSAttributedString {
        let attachment: LTXAttachment = .init()
        let mathView = viewProvider.acquireMathImageView()
        mathView.configure(image: image, text: representText, theme: theme)
        attachment.view = mathView
        attachment.size = mathView.intrinsicContentSize

        return NSAttributedString(
            string: LTXReplacementText,
            attributes: [
                LTXAttachmentAttributeName: attachment,
                kCTRunDelegateAttributeName as NSAttributedString.Key: attachment.runDelegate,
            ]
        )
    }

    func placeMathImage(theme: MarkdownTheme, image: UIImage, text: String, viewProvider: DrawingViewProvider) -> NSAttributedString {
        let attachment: LTXAttachment = .init()
        let mathView = viewProvider.acquireMathImageView()
        mathView.configure(image: image, text: text, theme: theme)
        attachment.view = mathView
        attachment.size = mathView.intrinsicContentSize

        return NSAttributedString(
            string: LTXReplacementText,
            attributes: [
                LTXAttachmentAttributeName: attachment,
                kCTRunDelegateAttributeName as NSAttributedString.Key: attachment.runDelegate,
            ]
        )
    }

    func render(theme: MarkdownTheme, renderedContext: RenderContext, viewProvider: DrawingViewProvider) -> NSAttributedString {
        assert(Thread.isMainThread)
        switch self {
        case let .text(string):
            return NSMutableAttributedString(
                string: string,
                attributes: [
                    .font: theme.fonts.body,
                    .foregroundColor: theme.colors.body,
                ]
            )
        case .softBreak:
            return NSAttributedString(string: " ", attributes: [
                .font: theme.fonts.body,
                .foregroundColor: theme.colors.body,
            ])
        case .lineBreak:
            return NSAttributedString(string: "\n", attributes: [
                .font: theme.fonts.body,
                .foregroundColor: theme.colors.body,
            ])
        case let .code(string):
            if let preRendered = renderedContext[string] {
                if let image = preRendered.image {
                    if string.hasPrefix("math://") {
                        let latex = preRendered.text
                        return placeMathImage(theme: theme, image: preRendered.image!, text: latex, viewProvider: viewProvider)
                    } else {
                        return placeImage(theme: theme, image: image, representText: preRendered.text, viewProvider: viewProvider)
                    }
                } else {
                    return NSAttributedString(
                        string: preRendered.text,
                        attributes: [
                            .font: theme.fonts.codeInline,
                            .foregroundColor: theme.colors.code,
                            .backgroundColor: theme.colors.codeBackground.withAlphaComponent(0.05),
                        ]
                    )
                }
            }
            return NSAttributedString(
                string: "\(string)",
                attributes: [
                    .font: theme.fonts.codeInline,
                    .foregroundColor: theme.colors.code,
                    .backgroundColor: theme.colors.codeBackground.withAlphaComponent(0.05),
                ]
            )
        case let .html(content):
            return NSAttributedString(
                string: "\(content)",
                attributes: [
                    .font: theme.fonts.codeInline,
                    .foregroundColor: theme.colors.code,
                    .backgroundColor: theme.colors.codeBackground.withAlphaComponent(0.05),
                ]
            )
        case let .emphasis(children):
            let ans = NSMutableAttributedString()
            children.map { $0.render(theme: theme, renderedContext: renderedContext, viewProvider: viewProvider) }.forEach { ans.append($0) }
            ans.addAttributes(
                [
                    .underlineStyle: NSUnderlineStyle.thick.rawValue,
                    .underlineColor: theme.colors.emphasis,
                ],
                range: NSRange(location: 0, length: ans.length)
            )
            return ans
        case let .strong(children):
            let ans = NSMutableAttributedString()
            children.map { $0.render(theme: theme, renderedContext: renderedContext, viewProvider: viewProvider) }.forEach { ans.append($0) }
            ans.addAttributes(
                [.font: theme.fonts.bold],
                range: NSRange(location: 0, length: ans.length)
            )
            return ans
        case let .strikethrough(children):
            let ans = NSMutableAttributedString()
            children.map { $0.render(theme: theme, renderedContext: renderedContext, viewProvider: viewProvider) }.forEach { ans.append($0) }
            ans.addAttributes(
                [.strikethroughStyle: NSUnderlineStyle.thick.rawValue],
                range: NSRange(location: 0, length: ans.length)
            )
            return ans
        case let .link(destination, children):
            let ans = NSMutableAttributedString()
            children.map { $0.render(theme: theme, renderedContext: renderedContext, viewProvider: viewProvider) }.forEach { ans.append($0) }
            ans.addAttributes(
                [
                    .link: destination,
                    .foregroundColor: theme.colors.highlight,
                ],
                range: NSRange(location: 0, length: ans.length)
            )
            return ans
        case let .image(source, _): // children => alternative text can be ignored?
            return NSAttributedString(
                string: source,
                attributes: [
                    .link: source,
                    .font: theme.fonts.body,
                    .foregroundColor: theme.colors.body,
                ]
            )
        }
    }
}

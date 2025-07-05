//
//  Created by ktiays on 2025/1/20.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import CoreText
import Litext
import MarkdownParser
import UIKit

// MARK: - BlockProcessor

final class BlockProcessor {
    private let theme: MarkdownTheme
    private let viewProvider: ReusableViewProvider
    private let thematicBreakDrawing: TextBuilder.DrawingCallback?
    private let codeDrawing: TextBuilder.DrawingCallback?
    private let tableDrawing: TextBuilder.DrawingCallback?

    init(
        theme: MarkdownTheme,
        viewProvider: ReusableViewProvider,
        thematicBreakDrawing: TextBuilder.DrawingCallback?,
        codeDrawing: TextBuilder.DrawingCallback?,
        tableDrawing: TextBuilder.DrawingCallback?
    ) {
        self.theme = theme
        self.viewProvider = viewProvider
        self.thematicBreakDrawing = thematicBreakDrawing
        self.codeDrawing = codeDrawing
        self.tableDrawing = tableDrawing
    }

    func processHeading(level _: Int, contents: [MarkdownInlineNode], renderedContext: RenderedTextContent.Map) -> NSAttributedString {
        let font: UIFont = theme.fonts.title

        return withParagraph { paragraph in
            paragraph.paragraphSpacing = 16
            paragraph.paragraphSpacingBefore = 16
        } content: {
            let string = contents.render(theme: theme, renderedContext: renderedContext, viewProvider: viewProvider)
            string.addAttributes(
                [.font: font],
                range: NSRange(location: 0, length: string.length)
            )
            return string
        }
    }

    func processParagraph(contents: [MarkdownInlineNode], renderedContext: RenderedTextContent.Map) -> NSAttributedString {
        withParagraph { paragraph in
            paragraph.paragraphSpacing = 16
            paragraph.lineSpacing = 4
        } content: {
            contents.render(theme: theme, renderedContext: renderedContext, viewProvider: viewProvider)
        }
    }

    func processThematicBreak() -> NSAttributedString {
        withParagraph {
            let drawingCallback = self.thematicBreakDrawing
            return .init(string: LTXReplacementText, attributes: [
                .font: theme.fonts.body,
                .ltxAttachment: LTXAttachment.hold(attrString: .init(string: "\n\n")),
                .ltxLineDrawingCallback: LTXLineDrawingAction(action: { context, line, lineOrigin in
                    drawingCallback?(context, line, lineOrigin)
                }),
            ])
        }
    }

    func processCodeBlock(language: String?, content: String) -> NSAttributedString {
        let content = content.deletingSuffix(of: .whitespacesAndNewlines)

        return withParagraph { paragraph in
            let height = CodeView.intrinsicHeight(for: content, theme: theme)
            paragraph.minimumLineHeight = height
        } content: {
            let codeView = viewProvider.acquireCodeView()
            codeView.theme = theme
            codeView.language = language ?? ""
            codeView.content = content
            let codeDrawing = self.codeDrawing
            return .init(string: LTXReplacementText, attributes: [
                .font: theme.fonts.body,
                .ltxAttachment: LTXAttachment.hold(attrString: .init(string: content + "\n")),
                .ltxLineDrawingCallback: LTXLineDrawingAction(action: { context, line, lineOrigin in
                    codeDrawing?(context, line, lineOrigin)
                }),
                .contextView: codeView,
            ])
        }
    }

    func processBlockquote(_ children: [MarkdownBlockNode], processor: (MarkdownBlockNode) -> NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for child in children {
            result.append(processor(child))
        }
        return result
    }

    func processTable(rows: [RawTableRow], renderedContext: RenderedTextContent.Map) -> NSAttributedString {
        let tableView = viewProvider.acquireTableView()
        let contents = rows.map {
            $0.cells.map { rawCell in
                rawCell.content.render(theme: theme, renderedContext: renderedContext, viewProvider: viewProvider)
            }
        }
        tableView.setContents(contents)
        return withParagraph { paragraph in
            paragraph.minimumLineHeight = tableView.intrinsicContentHeight
        } content: {
            let drawingCallback = self.tableDrawing
            return .init(string: LTXReplacementText, attributes: [
                .font: theme.fonts.body,
                .ltxAttachment: LTXAttachment.hold(attrString: .init(string: contents.map {
                    $0.map(\.string).joined(separator: "\t")
                }.joined(separator: "\n") + "\n")),
                .ltxLineDrawingCallback: LTXLineDrawingAction(action: { context, line, lineOrigin in
                    tableView.setContents(contents)
                    drawingCallback?(context, line, lineOrigin)
                }),
                .contextView: tableView,
            ])
        }
    }
}

// MARK: - Paragraph Helper

extension BlockProcessor {
    private func withParagraph(
        modifier: (NSMutableParagraphStyle) -> Void = { _ in },
        content: () -> NSMutableAttributedString
    ) -> NSMutableAttributedString {
        let paragraphStyle: NSMutableParagraphStyle = .init()
        paragraphStyle.paragraphSpacing = 16
        paragraphStyle.lineSpacing = 4
        modifier(paragraphStyle)

        let string = content()
        string.addAttributes(
            [.paragraphStyle: paragraphStyle],
            range: .init(location: 0, length: string.length)
        )
        string.append(.init(string: "\n"))
        return string
    }
}

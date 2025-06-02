//
//  Created by ktiays on 2025/1/20.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import CoreText
import Litext
import MarkdownParser
import UIKit

final class TextBuilder {
    private let nodes: [MarkdownBlockNode]
    private let viewProvider: DrawingViewProvider
    private var theme: MarkdownTheme
    private let text: NSMutableAttributedString = .init()
    private let preRenderedContent: PreRenderedContentMap

    private var bulletDrawing: BulletDrawingCallback?
    private var numberedDrawing: NumberedDrawingCallback?
    private var checkboxDrawing: CheckboxDrawingCallback?
    private var thematicBreakDrawing: DrawingCallback?
    private var codeDrawing: DrawingCallback?
    private var tableDrawing: DrawingCallback?

    var listIndent: CGFloat = 20

    init(nodes: [MarkdownBlockNode], preRenderedContent: PreRenderedContentMap, viewProvider: DrawingViewProvider) {
        self.nodes = nodes
        self.preRenderedContent = preRenderedContent
        self.viewProvider = viewProvider
        theme = .default
    }

    func withTheme(_ theme: MarkdownTheme) -> TextBuilder {
        self.theme = theme
        return self
    }

    func withBulletDrawing(_ drawing: @escaping BulletDrawingCallback) -> TextBuilder {
        bulletDrawing = drawing
        return self
    }

    func withNumberedDrawing(_ drawing: @escaping NumberedDrawingCallback) -> TextBuilder {
        numberedDrawing = drawing
        return self
    }

    func withCheckboxDrawing(_ drawing: @escaping CheckboxDrawingCallback) -> TextBuilder {
        checkboxDrawing = drawing
        return self
    }

    func withThematicBreakDrawing(_ drawing: @escaping DrawingCallback) -> TextBuilder {
        thematicBreakDrawing = drawing
        return self
    }

    func withCodeDrawing(_ drawing: @escaping DrawingCallback) -> TextBuilder {
        codeDrawing = drawing
        return self
    }

    func withTableDrawing(_ drawing: @escaping DrawingCallback) -> TextBuilder {
        tableDrawing = drawing
        return self
    }

    func build() -> NSAttributedString {
        for node in nodes {
            text.append(processBlock(node, preRenderedContent: preRenderedContent))
        }
        return text
    }
}

// MARK: - Block Processing

extension TextBuilder {
    private func processBlock(_ node: MarkdownBlockNode, preRenderedContent: PreRenderedContentMap) -> NSAttributedString {
        let blockProcessor = BlockProcessor(
            theme: theme,
            viewProvider: viewProvider,
            thematicBreakDrawing: thematicBreakDrawing,
            codeDrawing: codeDrawing,
            tableDrawing: tableDrawing
        )

        let listProcessor = ListProcessor(
            theme: theme,
            listIndent: listIndent,
            bulletDrawing: bulletDrawing,
            numberedDrawing: numberedDrawing,
            checkboxDrawing: checkboxDrawing
        )

        switch node {
        case let .heading(level, contents):
            return blockProcessor.processHeading(level: level, contents: contents, preRenderedContent: preRenderedContent)
        case let .paragraph(contents):
            return blockProcessor.processParagraph(contents: contents, preRenderedContent: preRenderedContent)
        case let .bulletedList(_, items):
            return listProcessor.processBulletedList(items: items, preRenderedContent: preRenderedContent)
        case let .numberedList(_, index, items):
            return listProcessor.processNumberedList(startAt: index, items: items, preRenderedContent: preRenderedContent)
        case let .taskList(_, items):
            return listProcessor.processTaskList(items: items, preRenderedContent: preRenderedContent)
        case .thematicBreak:
            return blockProcessor.processThematicBreak()
        case let .codeBlock(language, content):
            return blockProcessor.processCodeBlock(language: language, content: content)
        case let .blockquote(children):
            return blockProcessor.processBlockquote(children) {
                self.processBlock($0, preRenderedContent: preRenderedContent)
            }
        case let .table(_, rows):
            return blockProcessor.processTable(rows: rows, preRenderedContent: preRenderedContent)
        }
    }
}

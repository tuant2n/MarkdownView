//
//  PreprocessContent.swift
//  MarkdownView
//
//  Created by 秋星桥 on 7/5/25.
//

import Foundation
import MarkdownParser

public extension MarkdownTextView {
    struct PreprocessContent {
        public let blocks: [MarkdownBlockNode]
        public let rendered: RenderedTextContent.Map
        public let highlightMaps: [Int: CodeHighlighter.HighlightMap]

        public init(
            blocks: [MarkdownBlockNode],
            rendered: RenderedTextContent.Map,
            highlightMaps: [Int: CodeHighlighter.HighlightMap]
        ) {
            self.blocks = blocks
            self.rendered = rendered
            self.highlightMaps = highlightMaps
        }

        public init(parserResult: MarkdownParser.ParseResult, theme: MarkdownTheme) {
            blocks = parserResult.document
            rendered = parserResult.render(theme: theme)

            var highlightMaps: [Int: CodeHighlighter.HighlightMap] = [:]
            var iterator: [MarkdownBlockNode] = parserResult.document
            while !iterator.isEmpty {
                let node = iterator.removeFirst()
                iterator.append(contentsOf: node.children)
                switch node {
                case let .codeBlock(fenceInfo, content):
                    let key = CodeHighlighter.current.key(for: content, language: fenceInfo)
                    let map = CodeHighlighter.current.highlight(key: key, content: content, language: fenceInfo)
                    highlightMaps[key] = map
                default: continue
                }
            }
            self.highlightMaps = highlightMaps
        }

        public init() {
            blocks = .init()
            rendered = .init()
            highlightMaps = .init()
        }
    }
}

public extension MarkdownParser.ParseResult {
    fileprivate func renderMathContent(_ theme: MarkdownTheme, _ renderedContexts: inout [String: RenderedTextContent]) {
        for (key, value) in mathContext {
            let image = MathRenderer.renderToImage(
                latex: value,
                fontSize: theme.fonts.body.pointSize,
                textColor: theme.colors.body
            )?.withRenderingMode(.alwaysTemplate)
            let renderedContext = RenderedTextContent(
                image: image,
                text: value
            )
            let replacementText = MarkdownParser.replacementText(for: .math, identifier: .init(key))
            renderedContexts[replacementText] = renderedContext
        }
    }

    func render(theme: MarkdownTheme) -> RenderedTextContent.Map {
        var renderedContexts: [String: RenderedTextContent] = [:]
        renderMathContent(theme, &renderedContexts)
        return renderedContexts
    }
}

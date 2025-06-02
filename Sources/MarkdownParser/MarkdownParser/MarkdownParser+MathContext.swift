//
//  MarkdownParser+MathContext.swift
//  MarkdownView
//
//  Created by 秋星桥 on 6/3/25.
//

import Foundation

private let mathPattern: NSRegularExpression? = {
    let patterns = [
        ###"\$\$([\s\S]*?)\$\$"###, // 块级公式 $$ ... $$
        ###"\\\\\[([\s\S]*?)\\\\\]"###, // 带转义的块级公式 \\[ ... \\]
        ###"\\\\\(([\s\S]*?)\\\\\)"###, // 带转义的行内公式 \\( ... \\)
        ###"\\\[[\s\S]*?(\\(\s|\S)+?\n)+?\\\]"###, // 带转义的块级公式 \[ ... \] 且存在多行
    ]
    let pattern = patterns.joined(separator: "|")
    guard let regex = try? NSRegularExpression(
        pattern: pattern,
        options: [
            .caseInsensitive,
            .allowCommentsAndWhitespace,
        ]
    ) else {
        assertionFailure("failed to create regex for math pattern")
        return nil
    }
    return regex
}()

public extension MarkdownParser {
    class MathContext {
        let document: String
        var indexedContent: String?

        public fileprivate(set) var indexedMathContent: [Int: String] = [:]

        init(preprocessText: String) {
            document = preprocessText
        }

        func process() {
            guard let regex = mathPattern else {
                assertionFailure()
                return
            }

            var document = document

            let matches = regex.matches(
                in: document,
                options: [],
                range: NSRange(location: 0, length: document.count)
            ).reversed()
            if matches.isEmpty { return }

            var indexer = 0
            for match in matches where match.numberOfRanges > 1 {
                var mathContentRange: NSRange?

                // find the longest capture group
                for rangeIndex in 1 ..< match.numberOfRanges {
                    let captureRange = match.range(at: rangeIndex)
                    if captureRange.location != NSNotFound {
                        mathContentRange = captureRange
                        break
                    }
                }

                guard let contentRange = mathContentRange else { continue }

                let fullMatchRange = match.range(at: 0)
                guard let fullRange = Range(fullMatchRange, in: document) else { continue }

                let mathIndex = indexer
                let mathContent = (document as NSString).substring(with: contentRange)

                indexer += 1

                indexedMathContent[mathIndex] = mathContent

                let replacement = " `math://\(mathIndex)` "
                document.replaceSubrange(fullRange, with: replacement)
            }

            indexedContent = document
        }
    }
}

private let mathPatternWithinBlock: NSRegularExpression? = {
    let patterns = [
        ###"\\\(([^\r\n]+?)\\\)"###, // 行内公式 \(...\)
//        ###"\( ([^\r\n]+?) \)"###, // 行内公式 ( ... )
        ###"\$([^\r\n]+?)\$"###, // 行内公式 $ ... $
    ]
    let pattern = patterns.joined(separator: "|")
    guard let regex = try? NSRegularExpression(
        pattern: pattern,
        options: [
            .caseInsensitive,
            .allowCommentsAndWhitespace,
        ]
    ) else {
        assertionFailure("failed to create regex for math pattern")
        return nil
    }
    return regex
}()

extension MarkdownParser {
    /// 从正则匹配结果中提取最长的捕获组内容
    private func extractLongestCaptureGroup(from match: NSTextCheckingResult, in text: String) -> String? {
        var longestCaptureRange: NSRange?

        for rangeIndex in 1 ..< match.numberOfRanges {
            let captureRange = match.range(at: rangeIndex)
            if captureRange.location != NSNotFound {
                if longestCaptureRange == nil || captureRange.length > longestCaptureRange!.length {
                    longestCaptureRange = captureRange
                }
            }
        }

        guard let range = longestCaptureRange else { return nil }
        return (text as NSString).substring(with: range)
    }

    func processInlineMathBlocks(_ nodes: [MarkdownBlockNode], mathContext: MathContext) -> [MarkdownBlockNode] {
        nodes.map { processInlineMathBlock($0, mathContext: mathContext) }.flatMap(\.self)
    }

    func processInlineMathBlock(_ node: MarkdownBlockNode, mathContext: MathContext) -> [MarkdownBlockNode] {
        switch node {
        case let .blockquote(children):
            return [.blockquote(children: processInlineMathBlocks(children, mathContext: mathContext))]
        case let .bulletedList(isTight, items):
            let processedItems = items.map { item in
                RawListItem(children: processInlineMathBlocks(item.children, mathContext: mathContext))
            }
            return [.bulletedList(isTight: isTight, items: processedItems)]
        case let .numberedList(isTight, start, items):
            let processedItems = items.map { item in
                RawListItem(children: processInlineMathBlocks(item.children, mathContext: mathContext))
            }
            return [.numberedList(isTight: isTight, start: start, items: processedItems)]
        case let .taskList(isTight, items):
            let processedItems = items.map { item in
                RawTaskListItem(isCompleted: item.isCompleted, children: processInlineMathBlocks(item.children, mathContext: mathContext))
            }
            return [.taskList(isTight: isTight, items: processedItems)]
        case let .paragraph(content):
            let processedContent = processInlineMathInNodes(content, mathContext: mathContext)
            return [.paragraph(content: processedContent)]
        case let .table(columnAlignments, rows):
            let processedRows = rows.map { row in
                let processedCells = row.cells.map { cell in
                    RawTableCell(content: processInlineMathInNodes(cell.content, mathContext: mathContext))
                }
                return RawTableRow(cells: processedCells)
            }
            return [.table(columnAlignments: columnAlignments, rows: processedRows)]
        default:
            return [node]
        }
    }

    private func processInlineMathInNodes(_ nodes: [MarkdownInlineNode], mathContext: MathContext) -> [MarkdownInlineNode] {
        var result: [MarkdownInlineNode] = []

        for node in nodes {
            switch node {
            case let .text(text):
                result.append(contentsOf: processInlineMathInText(text, mathContext: mathContext))
            default:
                result.append(node)
            }
        }

        return result
    }

    private func processInlineMathInText(_ text: String, mathContext: MathContext) -> [MarkdownInlineNode] {
        guard let regex = mathPatternWithinBlock else {
            return [.text(text)]
        }

        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

        if matches.isEmpty {
            return [.text(text)]
        }

        var result: [MarkdownInlineNode] = []
        var lastEnd = 0

        for match in matches {
            let fullRange = match.range(at: 0)

            // 找到最长的捕获组
            guard let mathContent = extractLongestCaptureGroup(from: match, in: text), !mathContent.isEmpty else {
                continue
            }

            // 添加匹配前的文本
            if fullRange.location > lastEnd {
                let beforeText = (text as NSString).substring(with: NSRange(location: lastEnd, length: fullRange.location - lastEnd))
                if !beforeText.isEmpty {
                    result.append(.text(beforeText))
                }
            }

            // 添加数学公式
            let mathIndex = mathContext.indexedMathContent.count
            mathContext.indexedMathContent[mathIndex] = mathContent
            result.append(.code("math://\(mathIndex)"))

            lastEnd = fullRange.location + fullRange.length
        }

        if lastEnd < text.count {
            let remainingText = (text as NSString).substring(from: lastEnd)
            if !remainingText.isEmpty {
                result.append(.text(remainingText))
            }
        }

        return result
    }
}

//
//  MarkdownParser+MathContext.swift
//  MarkdownView
//
//  Created by 秋星桥 on 6/3/25.
//

import Foundation

private let mathPattern: NSRegularExpression? = {
    let patterns = [
        ###"\$([\s\S]*?)\$"###, // 行内公式 $ ... $
        ###"\$\$([\s\S]*?)\$\$"###, // 块级公式 $$ ... $$
        ###"\\\[([\s\S]*?)\\\]"###, // 带转义的块级公式 \\[ ... \\]
        ###"\\\(([\s\S]*?)\\\)"###, // 带转义的行内公式 \\( ... \\)
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

        public private(set) var indexedMathContent: [Int: String] = [:]

        init(preprocessText: String) {
            document = preprocessText
        }

        func process() {
            assert(!Thread.isMainThread)

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
                range_loop: for range in 1 ..< match.numberOfRanges {
                    let mathRange = match.range(at: range)
                    guard mathRange.location != NSNotFound,
                          let range = Range(mathRange, in: document)
                    else { continue }

                    let mathIndex = indexer
                    let mathContent = (document as NSString).substring(with: mathRange)

                    defer { indexer += 1 }

                    indexedMathContent[mathIndex] = mathContent

                    let replacement = "`math://\(mathIndex)`"
                    document.replaceSubrange(range, with: replacement)

                    continue range_loop
                }
            }

            indexedContent = document
        }
    }
}

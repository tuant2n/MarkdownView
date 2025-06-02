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
        ###"\$([\s\S]*?)\$"###, // 行内公式 $ ... $
        ###"\\\\\[([\s\S]*?)\\\\\]"###, // 带转义的块级公式 \\[ ... \\]
        ###"\\\\\(([\s\S]*?)\\\\\)"###, // 带转义的行内公式 \\( ... \\)
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

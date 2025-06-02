//
//  MathRenderer.swift
//  MarkdownView
//
//  Created by 秋星桥 on 5/26/25.
//

import Foundation
import LRUCache
import SwiftMath
import UIKit

enum MathRenderer {
    enum ContentType {
        case text
        case math
    }

    static let renderCache = LRUCache<String, UIImage>(countLimit: 256)

    struct ParsedContent {
        let type: ContentType
        let content: String
        let attributes: [NSAttributedString.Key: Any]

        init(type: ContentType, content: String, attributes: [NSAttributedString.Key: Any] = [:]) {
            self.type = type
            self.content = content
            self.attributes = attributes
        }
    }

    static let mathPattern: NSRegularExpression? = {
        let patterns = [
            ###"\$([\s\S]*?)\$"###,           // 行内公式 $ ... $
            ###"\$\$([\s\S]*?)\$\$"###,       // 块级公式 $$ ... $$
            ###"\\\[([\s\S]*?)\\\]"###,       // 带转义的块级公式 \\[ ... \\]
            ###"\\\(([\s\S]*?)\\\)"###,       // 带转义的行内公式 \\( ... \\)
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

    static func parseMathInText(_ text: NSString, textAttributes: [NSAttributedString.Key: Any] = [:]) -> [ParsedContent] {
        guard let regex = mathPattern else {
            assertionFailure()
            return [ParsedContent(type: .text, content: text as String, attributes: textAttributes)]
        }

        let matches = regex.matches(in: text as String, options: [], range: NSRange(location: 0, length: text.length))
        if matches.isEmpty {
            return [ParsedContent(type: .text, content: text as String, attributes: textAttributes)]
        }
        var results: [ParsedContent] = []
        var lastRange = NSRange(location: 0, length: 0)

        for match in matches {
            let matchRange = match.range
            
            // Add text before the math expression
            if matchRange.location > lastRange.location + lastRange.length {
                let textRange = NSRange(
                    location: lastRange.location + lastRange.length,
                    length: matchRange.location - (lastRange.location + lastRange.length)
                )
                let textContent = text.substring(with: textRange)
                results.append(ParsedContent(type: .text, content: textContent, attributes: textAttributes))
            }
            
            // Get the math content from the first capture group
            if match.numberOfRanges > 1, let captureRange = Range(match.range(at: 1), in: text as String) {
                let mathContent = String((text as String)[captureRange])
                results.append(ParsedContent(type: .math, content: mathContent, attributes: textAttributes))
            }
            
            lastRange = matchRange
        }

        // Add remaining text after the last match
        if lastRange.location + lastRange.length < text.length {
            let textRange = NSRange(
                location: lastRange.location + lastRange.length,
                length: text.length - (lastRange.location + lastRange.length)
            )
            let textContent = text.substring(with: textRange)
            results.append(ParsedContent(type: .text, content: textContent, attributes: textAttributes))
        }
        
        print(results)
        return results
    }

    static func renderToImage(
        latex: String,
        fontSize: CGFloat = 16,
        textColor: UIColor = .black
    ) -> UIImage? {
        if let cachedImage = renderCache.value(forKey: latex) {
            return cachedImage
        }

        let mathImage = MTMathImage(
            latex: latex,
            fontSize: fontSize,
            textColor: textColor,
            labelMode: .text
        )
        let (error, image) = mathImage.asImage()
        guard error == nil, let image else { return nil }
        renderCache.setValue(image, forKey: latex)

        return image
    }
}

// MARK: - String Extension

private extension String {
    func substring(with range: NSRange) -> String? {
        guard let swiftRange = Range(range, in: self) else { return nil }
        return String(self[swiftRange])
    }
}

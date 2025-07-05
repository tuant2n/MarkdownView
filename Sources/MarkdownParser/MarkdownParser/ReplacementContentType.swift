//
//  ReplacementContentType.swift
//  MarkdownView
//
//  Created by 秋星桥 on 7/5/25.
//

import Foundation

public extension MarkdownParser {
    static func replacementText(for contentType: String, identifier: String) -> String {
        "`" + "md://content?type=\(contentType)&index=\(identifier)" + "`"
    }

    enum ReplacementContentType: String {
        case unknown
        case math
    }

    static func replacementText(for contentType: ReplacementContentType, identifier: String) -> String {
        replacementText(for: contentType.rawValue, identifier: identifier)
    }

    static func typeForReplacementText(_ text: String) -> ReplacementContentType {
        let text = text.trimmingCharacters(in: .init(charactersIn: "`"))
        assert(text.hasPrefix("md://content?type="))
        guard let comps = URLComponents(string: text) else {
            assertionFailure()
            return .unknown
        }
        for queryItem in comps.queryItems ?? [] where queryItem.name == "type" {
            guard let value = queryItem.value else {
                assertionFailure()
                return .unknown
            }
            guard let type = ReplacementContentType(rawValue: value) else {
                assertionFailure()
                return .unknown
            }
            return type
        }
        assertionFailure()
        return .unknown
    }
}

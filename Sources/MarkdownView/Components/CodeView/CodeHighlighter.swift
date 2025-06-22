//
//  Created by ktiays on 2025/1/22.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import Foundation
import Splash
import UIKit

// MARK: - Highlight Result

enum HighlightResult {
    case success(NSAttributedString)
    case cancelled
    case error(String)
}

// MARK: - Highlight Request

struct HighlightRequest {
    let id: UUID
    let content: String
    let language: String
    let callerIdentifier: UUID
    let theme: MarkdownTheme
    let completion: (HighlightResult) -> Void
    let timestamp: Date

    init(
        content: String,
        language: String,
        callerIdentifier: UUID,
        theme: MarkdownTheme,
        completion: @escaping (HighlightResult) -> Void
    ) {
        id = UUID()
        self.content = content
        self.language = language
        self.callerIdentifier = callerIdentifier
        self.theme = theme
        self.completion = completion
        timestamp = Date()
    }
}

// MARK: - Code Highlighter

final class CodeHighlighter {
    // MARK: - Singleton

    static let shared = CodeHighlighter()

    // MARK: - Properties

    private let processingQueue: DispatchQueue
    private let requestQueue: DispatchQueue
    private var highlightQueue: [HighlightRequest] = []
    private var isProcessing = false
    private var currentRequest: HighlightRequest?

    // MARK: - Initialization

    private init() {
        processingQueue = DispatchQueue.global(qos: .userInitiated)
        requestQueue = DispatchQueue(label: "com.markdownview.highlighter.queue", qos: .userInitiated)
    }

    // MARK: - Public Methods

    func submitHighlightRequest(
        content: String,
        language: String = "",
        callerIdentifier: UUID,
        theme: MarkdownTheme,
        completion: @escaping (HighlightResult) -> Void
    ) {
        let request = HighlightRequest(
            content: content,
            language: language,
            callerIdentifier: callerIdentifier,
            theme: theme,
            completion: completion
        )

        requestQueue.async { [weak self] in
            self?.enqueueRequest(request)
        }
    }

    // MARK: - Private Methods

    private func enqueueRequest(_ request: HighlightRequest) {
        highlightQueue.removeAll { $0.callerIdentifier == request.callerIdentifier }
        highlightQueue.append(request)
        if !isProcessing { processNextRequest() }
    }

    private func processNextRequest() {
        guard !highlightQueue.isEmpty else {
            isProcessing = false
            return
        }

        isProcessing = true
        let request = highlightQueue.removeFirst()
        currentRequest = request

        processingQueue.async { [weak self] in
            self?.performHighlight(for: request)
        }
    }

    private func performHighlight(for request: HighlightRequest) {
        let codeTheme = request.theme.codeTheme(withFont: request.theme.fonts.code)
        let format = AttributedStringOutputFormat(theme: codeTheme)

        let result = performHighlight(
            code: request.content,
            language: request.language,
            format: format
        )

        guard let attributedString = result else {
            DispatchQueue.main.async {
                request.completion(.error("Failed to highlight code"))
            }
            completeCurrentRequest()
            return
        }

        requestQueue.async { [weak self] in
            guard let self else { return }
            let hasNewRequest = highlightQueue.contains { $0.callerIdentifier == request.callerIdentifier }
            DispatchQueue.main.async {
                if hasNewRequest {
                    request.completion(.cancelled)
                } else {
                    request.completion(.success(attributedString))
                }
            }
            completeCurrentRequest()
        }
    }

    private func completeCurrentRequest() {
        requestQueue.async { [weak self] in
            self?.currentRequest = nil
            self?.processNextRequest()
        }
    }

    private func performHighlight(
        code: String,
        language: String,
        format: AttributedStringOutputFormat
    ) -> NSMutableAttributedString? {
        switch language.lowercased() {
        case "", "plaintext":
            return NSMutableAttributedString(string: code)
        case "swift":
            let splash = SyntaxHighlighter(format: format, grammar: SwiftGrammar())
            return splash.highlight(code).mutableCopy() as? NSMutableAttributedString
        default:
            let splash = SyntaxHighlighter(format: format)
            return splash.highlight(code).mutableCopy() as? NSMutableAttributedString
        }
    }

    private func extractColorAttributes(from attributedString: NSMutableAttributedString) -> [NSRange: UIColor] {
        var attributes: [NSRange: UIColor] = [:]
        let nsString = attributedString.string as NSString

        attributedString.enumerateAttribute(
            .foregroundColor,
            in: NSRange(location: 0, length: attributedString.length)
        ) { value, range, _ in
            if range.length == 1 {
                if let char = nsString.substring(with: range).first, char.isWhitespace {
                    return
                }
            }

            guard let color = value as? UIColor else { return }
            attributes[range] = color
        }

        return attributes
    }
}

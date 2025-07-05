//
//  Created by ktiays on 2025/1/22.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import Foundation
import OrderedCollections
import Splash
import UIKit

private let kMaxCacheSize = 64 // for each language
private let kPrefixLength = 8

public final class CodeHighlighter {
    public typealias HighlightMap = [NSRange: UIColor]
    public enum RenderCacheMatch {
        case full(map: HighlightMap)
        case prefix(map: HighlightMap)
        case none
    }

    public typealias HashValue = Int
    public typealias Language = String
    public struct RenderCache {
        // used to remove old, we keep at most kMaxCacheSize entries
        let sequence: UInt64
        let language: String
        var content: String
        var map: HighlightMap

        // use first kPrefixLength characters + lang with left padding _ to match the cache
        var prefixHash: HashValue
    }

    public private(set) var renderCache = OrderedDictionary<HashValue, [RenderCache]>()
    private let cacheLock = NSLock()
    private var cacheSequence: UInt64 = 0

    public struct HighlightRequest {
        let taskIdentifier: UUID
        // bind to view, cancell previous request with same identifier
        let callerIdentifier: UUID
        let language: String
        let content: String
        let theme: MarkdownTheme

        init(taskIdentifier: UUID, callerIdentifier: UUID, language: String, content: String, theme: MarkdownTheme) {
            self.taskIdentifier = taskIdentifier
            self.callerIdentifier = callerIdentifier
            self.language = language
            self.theme = theme

            var content = content
            while content.hasSuffix("`") {
                content.removeLast()
            }
            while content.hasSuffix("\n") {
                content.removeLast()
            }
            self.content = content
        }
    }

    public enum HighlightResult {
        case cache(task: UUID, HighlightMap)
        case highlighted(task: UUID, HighlightMap)
    }

    private var highlightRequestQueue: [HighlightRequest] = []
    private let queueLock = NSLock()
    private let queue = DispatchQueue(label: "wiki.qaq.render.exec", qos: .userInteractive)
    private var currentTask: UUID?

    private init() {}
    public static let current = CodeHighlighter()
}

public extension CodeHighlighter {
    func hash(language: String, content: String) -> HashValue {
        let language = language.lowercased()
        if content.count < kPrefixLength {
            // the string is small, do not use prefix hash for this
            // do the full iteration over commonPrefix later
            return language.hashValue
        } else {
            // now we use prefix to quickly identify the code
            let hasher = language + content.prefix(kPrefixLength)
            return hasher.hashValue
        }
    }

    func commonPrefixLength(lhs: String, rhs: String) -> UInt64 {
        var matchIndexer = UInt64(0)

        var lhsIter = lhs.makeIterator()
        var lhsEnd = false
        var rhsIter = rhs.makeIterator()
        var rhsEnd = false

        // O(n) scan the content until we reach a mismatch
        while !lhsEnd, !rhsEnd {
            let lhsc = lhsIter.next()
            lhsEnd = lhsc == nil
            let rhsc = rhsIter.next()
            rhsEnd = rhsc == nil
            guard let lhsc, let rhsc, lhsc == rhsc else { break }
            matchIndexer += 1
        }
        return matchIndexer
    }

    func contentMatch(cache: RenderCache, incomingText: String) -> RenderCacheMatch {
        // to match a cache, incomingText must be equal or longer than the cached content
        let cacheContent = cache.content
        guard incomingText.count >= cacheContent.count else {
            return .none
        }

        let commonPrefixLen = commonPrefixLength(lhs: cache.content, rhs: incomingText)
        if commonPrefixLen == 0 { return .none }
        if commonPrefixLen == incomingText.count {
            return .full(map: cache.map)
        }
        assert(commonPrefixLen < incomingText.utf16.count)
        var partialMap = HighlightMap()
        for (range, color) in cache.map {
            guard range.location < commonPrefixLen else {
                // this range is beyond the matched prefix, skip
                continue
            }
            assert(range.length > 0)
            // adjust the range to match the incoming text
            let adjustedRange = NSRange(
                location: range.location,
                length: min(range.length, .init(commonPrefixLen) - range.length)
            )
            if adjustedRange.length > 0 {
                partialMap[adjustedRange] = color
            }
        }
        return .prefix(map: partialMap)
    }

    func cache(matching prefix: HashValue) -> [RenderCache] {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return renderCache[prefix] ?? []
    }

    func lookup(
        language: String,
        content: String
    ) -> RenderCacheMatch {
        let prefixHash = hash(language: language, content: content)
        let cache = cache(matching: prefixHash)
        for entry in cache {
            // language is in the prefix hash so do a check
            assert(entry.language == language)
            let match = contentMatch(cache: entry, incomingText: content)
            if case .none = match { continue }
            return match
        }
        return .none
    }

    func beginHighlight(request: HighlightRequest, onEvent: @escaping (HighlightResult) -> Void) {
        guard !request.content.isEmpty else { return } // well, wdym?

        let match = lookup(language: request.language, content: request.content)
        switch match {
        case let .full(map):
            onEvent(.cache(task: request.taskIdentifier, map))
            return
        case let .prefix(map):
            onEvent(.cache(task: request.taskIdentifier, map))
        case .none:
            break
        }

        queueLock.lock()
        highlightRequestQueue.removeAll { $0.callerIdentifier == request.callerIdentifier }
        highlightRequestQueue.append(request)
        queueLock.unlock()

        autoreleasepool {
            executeHighlight(taskIdentifier: request.taskIdentifier) { map in
                onEvent(.highlighted(task: request.taskIdentifier, map))
            }
        }
    }

    func cancelHighlight(callerIdentifier: UUID) {
        queueLock.lock()
        highlightRequestQueue.removeAll { $0.callerIdentifier == callerIdentifier }
        queueLock.unlock()
    }

    func cancelHighlight(taskIdentifier: UUID) {
        queueLock.lock()
        highlightRequestQueue.removeAll { $0.taskIdentifier == taskIdentifier }
        queueLock.unlock()
    }

    func clearCache() {
        cacheLock.lock()
        renderCache.removeAll()
        cacheSequence = 0
        cacheLock.unlock()
    }
}

private extension CodeHighlighter {
    func executeHighlight(taskIdentifier: UUID, onCompletion: @escaping (HighlightMap) -> Void) {
        queue.async { [self] in
            assert(!Thread.isMainThread)

            assert(currentTask == nil)
            currentTask = taskIdentifier
            defer { currentTask = nil }

            // remove this item from queue and process it
            queueLock.lock()
            var request: HighlightRequest?
            highlightRequestQueue.removeAll {
                if request != nil { return false }
                let isTarget = $0.taskIdentifier == taskIdentifier
                guard isTarget else { return false }
                request = $0
                return true
            }
            queueLock.unlock()

            guard let request else { return }
            // now we are good to go

            let highlightedAttributeString = highlightedAttributeString(
                language: request.language,
                content: request.content,
                theme: request.theme
            )
            let map = extractColorAttributes(from: highlightedAttributeString)
            let prefixHash = hash(language: request.language, content: request.content)
            cacheSequence += 1
            let cache = RenderCache(
                sequence: cacheSequence,
                language: request.language,
                content: request.content,
                map: map,
                prefixHash: prefixHash
            )

            cacheLock.lock()
            insertCache(cache)
            compactRenderCacheIfNeededWithoutLock()
            cacheLock.unlock()

            // completed render
            onCompletion(cache.map)
        }
    }

    func insertCache(_ cache: RenderCache) {
        var currentPrefixCaches = renderCache[cache.prefixHash] ?? [] // prefix includes language
        let replaceIndex = currentPrefixCaches.firstIndex { oldCache in
            let commonPrefixLen = self.commonPrefixLength(
                lhs: oldCache.content,
                rhs: cache.content
            )
            if commonPrefixLen == oldCache.content.count {
                return true
            }
            return false
        }
        if let replaceIndex {
            // so we keep seq sorted
            currentPrefixCaches.remove(at: replaceIndex)
        }
        currentPrefixCaches.append(cache)
        renderCache[cache.prefixHash] = currentPrefixCaches
    }

    func compactRenderCacheIfNeededWithoutLock() {
        // remove cache that is too large
        var numberOfRenderCacheToRemove = max(
            0,
            renderCache.values.map(\.count).reduce(0, +) - kMaxCacheSize
        )
        while numberOfRenderCacheToRemove > 0 {
            numberOfRenderCacheToRemove -= 1
            guard !renderCache.isEmpty else {
                assertionFailure()
                break
            }

            var oldestKey: HashValue?
            var oldestSequence = UInt64.max

            // it is ordered values to have oldest first
            for (key, caches) in renderCache {
                if let cache = caches.first, cache.sequence < oldestSequence {
                    oldestSequence = cache.sequence
                    oldestKey = key
                }
            }

            if let key = oldestKey {
                renderCache[key]?.removeFirst()
                if renderCache[key]?.isEmpty == true {
                    renderCache.removeValue(forKey: key)
                }
            }
        }
    }

    func highlightedAttributeString(language: String, content: String, theme: MarkdownTheme) -> NSAttributedString {
        let codeTheme = theme.codeTheme(withFont: theme.fonts.code)
        let format = AttributedStringOutputFormat(theme: codeTheme)
        let base = {
            switch language.lowercased() {
            case "text", "plaintext":
                return NSAttributedString(string: content)
            case "swift":
                let splash = SyntaxHighlighter(format: format, grammar: SwiftGrammar())
                return splash.highlight(content)
            default:
                let splash = SyntaxHighlighter(format: format)
                return splash.highlight(content)
            }
        }()
        guard let finalizer = base.mutableCopy() as? NSMutableAttributedString else {
            return .init()
        }
        finalizer.addAttributes([
            .font: codeTheme.font,
        ], range: .init(location: 0, length: finalizer.length))
        return finalizer
    }

    func extractColorAttributes(from attributedString: NSAttributedString) -> HighlightMap {
        var attributes: [NSRange: UIColor] = [:]

        attributedString.enumerateAttribute(
            .foregroundColor,
            in: NSRange(location: 0, length: attributedString.length)
        ) { value, range, _ in
            guard let color = value as? UIColor else { return }
            attributes[range] = color
        }

        return attributes
    }
}

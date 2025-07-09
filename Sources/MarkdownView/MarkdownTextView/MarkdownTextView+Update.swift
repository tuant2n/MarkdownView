//
//  MarkdownTextView+Update.swift
//  MarkdownView
//
//  Created by 秋星桥 on 7/9/25.
//

import CoreText
import Litext
import UIKit

extension MarkdownTextView {
    func updateTextExecute() {
        assert(Thread.isMainThread)

        viewProvider.lockPool()
        defer { viewProvider.unlockPool() }

        var pendingReleasedViews: Set<UIView> = .init()
        for view in contextViews {
            pendingReleasedViews.insert(view)
            if let view = view as? CodeView {
                viewProvider.stashCodeView(view)
                continue
            }
            if let view = view as? TableView {
                viewProvider.stashTableView(view)
                continue
            }
            assertionFailure()
        }

        viewProvider.reorderViews(matching: contextViews)
        contextViews.removeAll()

        let artifacts = TextBuilder.build(view: self)
        textView.attributedText = artifacts.document
        contextViews = artifacts.subviews

        for viewToRemove in pendingReleasedViews where !artifacts.subviews.contains(viewToRemove) {
            viewToRemove.removeFromSuperview()
        }

        textView.setNeedsLayout()
        setNeedsLayout()

        textView.setNeedsDisplay()
        setNeedsDisplay()
    }
}

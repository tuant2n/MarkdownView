//
//  MarkdownTextView+LTXDelegate.swift
//  MarkdownView
//
//  Created by 秋星桥 on 7/9/25.
//

import Litext
import UIKit

extension MarkdownTextView: LTXLabelDelegate {
    public func ltxLabelSelectionDidChange(_: Litext.LTXLabel, selection _: NSRange?) {
        // reserved for future use
    }

    public func ltxLabelDetectedUserEventMovingAtLocation(_: Litext.LTXLabel, location _: CGPoint) {
        // reserved for future use
    }

    public func ltxLabelDidTapOnHighlightContent(_: LTXLabel, region: LTXHighlightRegion?, location: CGPoint) {
        guard let highlightRegion = region else {
            return
        }
        let link = highlightRegion.attributes[NSAttributedString.Key.link]
        let range = highlightRegion.stringRange
        if let url = link as? URL {
            linkHandler?(.url(url), range, location)
        } else if let string = link as? String {
            linkHandler?(.string(string), range, location)
        }
    }
}

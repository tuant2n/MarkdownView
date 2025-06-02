//
//  PreRenderedContent.swift
//  MarkdownView
//
//  Created by 秋星桥 on 6/3/25.
//

import UIKit

public typealias PreRenderedContentMap = [String: PreRenderedContent]

public struct PreRenderedContent {
    public let image: UIImage?
    public let text: String
}

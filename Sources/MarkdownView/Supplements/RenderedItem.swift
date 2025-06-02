//
//  RenderedItem.swift
//  MarkdownView
//
//  Created by 秋星桥 on 6/3/25.
//

import UIKit

public typealias RenderContext = [String: RenderedItem]

public struct RenderedItem {
    public let image: UIImage?
    public let text: String

    public init(image: UIImage?, text: String) {
        self.image = image
        self.text = text
    }
}

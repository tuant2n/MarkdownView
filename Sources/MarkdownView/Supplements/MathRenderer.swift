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

public enum MathRenderer {
    static let renderCache = LRUCache<String, UIImage>(countLimit: 256)

    public static func renderToImage(
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

        print("[i] MathRenderer has completed a task for content: \(latex)")
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

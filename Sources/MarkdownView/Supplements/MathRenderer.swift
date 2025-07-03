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

    private static func preprocessLatex(_ latex: String) -> String {
        latex
            .replacingOccurrences(of: "\\dots", with: "\\ldots")
            .replacingOccurrences(of: "\\implies", with: "\\Rightarrow")
            .replacingOccurrences(of: "\\begin{align}", with: "\\begin{aligned}")
            .replacingOccurrences(of: "\\end{align}", with: "\\end{aligned}")
            .replacingOccurrences(of: "\\begin{align*}", with: "\\begin{aligned}")
            .replacingOccurrences(of: "\\end{align*}", with: "\\end{aligned}")
            .replacingOccurrences(of: "\\begin{cases}", with: "\\left\\{\\begin{matrix}")
            .replacingOccurrences(of: "\\end{cases}", with: "\\end{matrix}\\right.")
    }

    public static func renderToImage(
        latex: String,
        fontSize: CGFloat = 16,
        textColor: UIColor = .black
    ) -> UIImage? {
        if let cachedImage = renderCache.value(forKey: latex) {
            return cachedImage
        }

        let processedLatex = preprocessLatex(latex)

        let mathImage = MTMathImage(
            latex: processedLatex,
            fontSize: fontSize,
            textColor: textColor,
            labelMode: .text
        )
        let (error, image) = mathImage.asImage()
        guard error == nil, let image else {
            print("[!] MathRenderer failed to render image for content: \(latex) \(error?.localizedDescription ?? "?")")
            return nil
        }
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

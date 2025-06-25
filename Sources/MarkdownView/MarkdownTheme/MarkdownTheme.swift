//
//  MarkdownTheme.swift
//  MarkdownView
//
//  Created by 秋星桥 on 2025/1/3.
//

import Foundation
import Splash
import UIKit

extension MarkdownTheme {
    public static var `default`: MarkdownTheme = .init()
    public static let codeScale = 0.85
}

public struct MarkdownTheme: Equatable {
    public struct Fonts: Equatable {
        public var body = UIFont.preferredFont(forTextStyle: .body)
        public var codeInline = UIFont.monospacedSystemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize,
            weight: .regular
        )
        public var bold = UIFont.preferredFont(forTextStyle: .body).bold
        public var italic = UIFont.preferredFont(forTextStyle: .body).italic
        public var code = UIFont.monospacedSystemFont(
            ofSize: ceil(UIFont.preferredFont(forTextStyle: .body).pointSize * codeScale),
            weight: .regular
        )
        public var largeTitle = UIFont.preferredFont(forTextStyle: .body).bold
        public var title = UIFont.preferredFont(forTextStyle: .body).bold
        public var footnote = UIFont.preferredFont(forTextStyle: .footnote)
    }

    public var fonts: Fonts = .init()

    public struct Colors: Equatable {
        public var body = UIColor.label
        public var highlight =
            UIColor(named: "AccentColor")
            ?? UIColor(named: "accentColor")
            ?? .systemOrange
        public var emphasis =
            UIColor(named: "AccentColor")
            ?? UIColor(named: "accentColor")
            ?? .systemOrange
        public var code = UIColor.label
        public var codeBackground = UIColor.gray.withAlphaComponent(0.25)
    }

    public var colors: Colors = .init()

    public struct Spacings: Equatable {
        public var final: CGFloat = 16
        public var general: CGFloat = 8
        public var list: CGFloat = 12
        public var cell: CGFloat = 32
    }

    public var spacings: Spacings = .init()

    public struct Sizes: Equatable {
        public var bullet: CGFloat = 4
    }

    public var sizes: Sizes = .init()

    public struct Table: Equatable {
        public var cornerRadius: CGFloat = 8
        public var borderWidth: CGFloat = 1
        public var borderColor = UIColor.separator
        public var headerBackgroundColor = UIColor.systemGray6
        public var cellBackgroundColor = UIColor.systemBackground
    }

    public var table: Table = .init()

    public init() {}
}

extension MarkdownTheme {
    public static var defaultValueFont: Fonts { Fonts() }
    public static var defaultValueColor: Colors { Colors() }
    public static var defaultValueSpacing: Spacings { Spacings() }
    public static var defaultValueSize: Sizes { Sizes() }
    public static var defaultValueTable: Table { Table() }
}

extension MarkdownTheme {
    public enum FontScale: String, CaseIterable {
        case tiny
        case small
        case middle
        case large
        case huge
    }
}

extension MarkdownTheme.FontScale {
    public var offset: Int {
        switch self {
        case .tiny: -4
        case .small: -2
        case .middle: 0
        case .large: 2
        case .huge: 4
        }
    }

    public func scale(_ font: UIFont) -> UIFont {
        let size = max(4, font.pointSize + CGFloat(offset))
        return font.withSize(size)
    }
}

extension MarkdownTheme {
    public mutating func scaleFont(by scale: FontScale) {
        let defaultFont = Self.defaultValueFont
        fonts.body = scale.scale(defaultFont.body)
        fonts.codeInline = scale.scale(defaultFont.codeInline)
        fonts.bold = scale.scale(defaultFont.bold)
        fonts.italic = scale.scale(defaultFont.italic)
        fonts.code = scale.scale(defaultFont.code)
        fonts.largeTitle = scale.scale(defaultFont.largeTitle)
        fonts.title = scale.scale(defaultFont.title)
    }

    public mutating func align(to pointSize: CGFloat) {
        fonts.body = fonts.body.withSize(pointSize)
        fonts.codeInline = fonts.codeInline.withSize(pointSize)
        fonts.bold = fonts.bold.withSize(pointSize).bold
        fonts.italic = fonts.italic.withSize(pointSize)
        fonts.code = fonts.code.withSize(pointSize * Self.codeScale)
        fonts.largeTitle = fonts.largeTitle.withSize(pointSize).bold
        fonts.title = fonts.title.withSize(pointSize).bold
    }
}

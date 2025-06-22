//
//  MathImageView.swift
//  MarkdownView
//
//  Created by 秋星桥 on 6/22/25.
//

import Litext
import SwiftMath
import UIKit

final class MathImageView: UIView {
    // MARK: - Properties
    
    var theme: MarkdownTheme = .default {
        didSet {
            updateAppearance()
        }
    }
    
    private var _image: UIImage?
    private var _text: String = ""
    
    // MARK: - UI Components
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func configureSubviews() {
        backgroundColor = .clear
        addSubview(imageView)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    override var intrinsicContentSize: CGSize {
        guard let image = _image else {
            return CGSize(width: 0, height: theme.fonts.body.lineHeight)
        }
        return image.size
    }
    
    // MARK: - Public Methods
    
    func configure(image: UIImage, text: String, theme: MarkdownTheme) {
        self._image = image
        self._text = text
        self.theme = theme
        updateAppearance()
    }
    
    func reset() {
        _image = nil
        _text = ""
        imageView.image = nil
    }
    
    // MARK: - Private Methods
    
    private func updateAppearance() {
        if let image = _image {
            imageView.image = image.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = theme.colors.body
        }
    }
}

// MARK: - LTXAttributeStringRepresentable

extension MathImageView: LTXAttributeStringRepresentable {
    func attributedStringRepresentation() -> NSAttributedString {
        .init(string: "<math>\(_text)</math>")
    }
} 

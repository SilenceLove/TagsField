//
//  WSTagView.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import UIKit

open class WSTagView: UIView, UITextInputTraits {

    fileprivate let textLabel = UILabel()

    open var displayText: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var displayDelimiter: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var font: UIFont? {
        didSet {
            textLabel.font = font
            setNeedsDisplay()
        }
    }

    open var cornerRadius: CGFloat = 3.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            setNeedsDisplay()
        }
    }

    open var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            setNeedsDisplay()
        }
    }

    open var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
                setNeedsDisplay()
            }
        }
    }

    /// Background color to be used for selected state.
    open var bgColor: UIColor = UIColor(red: 0, green: 0.47843137254901963, blue: 1, alpha: 1) {
        didSet { updateContent(animated: false) }
    }
    
    open var selectedColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var textColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var selectedTextColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    internal var onDidRequestDelete: ((_ tagView: WSTagView, _ replacementText: String?) -> Void)?
    internal var onDidRequestSelection: ((_ tagView: WSTagView) -> Void)?
    internal var onDidInputText: ((_ tagView: WSTagView, _ text: String) -> Void)?

    open var selected: Bool = false {
        didSet {
            if oldValue == selected {
                return
            }
//            if selected && !isFirstResponder {
//                _ = becomeFirstResponder()
//            }
//            else if !selected && isFirstResponder {
//                _ = resignFirstResponder()
//            }
            updateContent(animated: true)
        }
    }

    // MARK: - UITextInputTraits

    public var autocapitalizationType: UITextAutocapitalizationType = .none
    public var autocorrectionType: UITextAutocorrectionType  = .no
    public var spellCheckingType: UITextSpellCheckingType  = .no
    public var keyboardType: UIKeyboardType = .default
    public var keyboardAppearance: UIKeyboardAppearance = .default
    public var returnKeyType: UIReturnKeyType = .next
    public var enablesReturnKeyAutomatically: Bool = false
    public var isSecureTextEntry: Bool = false

    // MARK: - Initializers

    public init(tag: WSTag) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = bgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        textColor = .white
        selectedColor = .gray
        selectedTextColor = .black

        textLabel.frame = CGRect(x: layoutMargins.left, y: layoutMargins.top, width: 0, height: 0)
        textLabel.font = font
        textLabel.textColor = .white
        textLabel.backgroundColor = .clear
        textLabel.numberOfLines = 0
        addSubview(textLabel)

        self.displayText = tag.text
        updateLabelText()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        addGestureRecognizer(tapRecognizer)
        setNeedsLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(false, "Not implemented")
    }

    // MARK: - Styling

    fileprivate func updateColors() {
        self.backgroundColor = selected ? selectedColor : bgColor
        textLabel.textColor = selected ? selectedTextColor : textColor
    }

    internal func updateContent(animated: Bool) {
        guard animated else {
            updateColors()
            return
        }
        layer.removeAllAnimations()
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.updateColors()
//                if self?.selected ?? false {
//                    self?.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
//                }
            },
            completion: { [weak self] _ in
//                if self?.selected ?? false {
//                    UIView.animate(withDuration: 0.1) { [weak self] in
//                        self?.transform = CGAffineTransform.identity
//                    }
//                }
            }
        )
    }

    // MARK: - Size Measurements

    open override var intrinsicContentSize: CGSize {
        let labelIntrinsicSize = textLabel.intrinsicContentSize
        return CGSize(width: labelIntrinsicSize.width + layoutMargins.left + layoutMargins.right,
                      height: labelIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layoutMarginsHorizontal = layoutMargins.left + layoutMargins.right
        let layoutMarginsVertical = layoutMargins.top + layoutMargins.bottom
        let fittingSize = CGSize(width: size.width - layoutMarginsHorizontal,
                                 height: size.height - layoutMarginsVertical)
        let labelSize = textLabel.sizeThatFits(fittingSize)
        return CGSize(width: labelSize.width + layoutMarginsHorizontal,
                      height: labelSize.height + layoutMarginsVertical)
    }

    open func sizeToFit(_ size: CGSize) -> CGSize {
        if intrinsicContentSize.width > size.width {
            if let font = textLabel.font,
               let height = textLabel.text?.height(ofFont: font, maxWidth: size.width - (layoutMargins.left + layoutMargins.right)) {
                return CGSize(width: size.width,
                              height: height + layoutMargins.top + layoutMargins.bottom)
            }
            return CGSize(width: size.width,
                          height: intrinsicContentSize.height)
        }
        return intrinsicContentSize
    }

    // MARK: - Attributed Text
    fileprivate func updateLabelText() {
        // Unselected shows "[displayText]," and selected is "[displayText]"
        textLabel.text = displayText + displayDelimiter
        // Expand Label
        let intrinsicSize = self.intrinsicContentSize
        frame = CGRect(x: 0, y: 0, width: intrinsicSize.width, height: intrinsicSize.height)
    }

    // MARK: - Laying out
    open override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds.inset(by: layoutMargins)
        if frame.width == 0 || frame.height == 0 {
            frame.size = self.intrinsicContentSize
        }
    }

    // MARK: - First Responder (needed to capture keyboard)
    open override var canBecomeFirstResponder: Bool {
        return true
    }

//    open override func becomeFirstResponder() -> Bool {
//        let didBecomeFirstResponder = super.becomeFirstResponder()
//        selected = true
//        return didBecomeFirstResponder
//    }

//    open override func resignFirstResponder() -> Bool {
//        let didResignFirstResponder = super.resignFirstResponder()
//        selected = false
//        if #available(iOS 13.0, *) {
//            UIMenuController.shared.hideMenu()
//        } else {
//            UIMenuController.shared.setMenuVisible(false, animated: true)
//        }
//        return didResignFirstResponder
//    }

    // MARK: - Gesture Recognizers
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
//        if selected {
//            return
//        }
        onDidRequestSelection?(self)
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
}

//extension WSTagView: UIKeyInput {
//
//    public var hasText: Bool {
//        return false
//    }
//
//    public func insertText(_ text: String) {
//        onDidInputText?(self, text)
//    }
//
//    public func deleteBackward() {
//        onDidRequestDelete?(self, nil)
//    }
//
//}

extension String {
    
    func size(ofAttributes attributes: [NSAttributedString.Key: Any], maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: maxWidth, height: maxHeight)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        return boundingBox.size
    }
    
    func height(ofFont font: UIFont, maxWidth: CGFloat) -> CGFloat {
        size(
            ofAttributes: [NSAttributedString.Key.font: font],
            maxWidth: maxWidth,
            maxHeight: CGFloat(MAXFLOAT)
        ).height
    }
}

//
//  BackspaceDetectingTextField.swift
//  WSTagsField
//
//  Created by Ilya Seliverstov on 11/07/2017.
//  Copyright © 2017 Whitesmith. All rights reserved.
//

import UIKit

protocol BackspaceDetectingTextFieldDelegate: UITextFieldDelegate {
    /// Notify whenever the backspace key is pressed
    func textFieldDidDeleteBackwards(_ textField: UITextField)
}

open class BackspaceDetectingTextField: UITextField {

    open var onDeleteBackwards: (() -> Void)?

    init() {
        super.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func deleteBackward() {
        onDeleteBackwards?()
        // Call super afterwards. The `text` property will return text prior to the delete.
        super.deleteBackward()
    }
    
    var isDisabledPerformAction: Bool = false

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if isDisabledPerformAction {
            
            if action == #selector(UIResponderStandardEditActions.paste(_:)) ||
                action == #selector(UIResponderStandardEditActions.select(_:)) ||
                action == #selector(UIResponderStandardEditActions.selectAll(_:)) ||
                action == #selector(UIResponderStandardEditActions.delete(_:)) ||
                action == #selector(UIResponderStandardEditActions.copy(_:)) ||
                action == #selector(UIResponderStandardEditActions.cut(_:)) ||
                action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionLeftToRight(_:)) ||
                action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionRightToLeft(_:)) ||
                action == #selector(UIResponderStandardEditActions.toggleBoldface(_:)) ||
                action == #selector(UIResponderStandardEditActions.toggleItalics(_:)) ||
                action == #selector(UIResponderStandardEditActions.toggleUnderline(_:)) ||
                action == #selector(UIResponderStandardEditActions.increaseSize(_:)) ||
                action == #selector(UIResponderStandardEditActions.decreaseSize(_:)) ||
                action == #selector(UIResponderStandardEditActions.toggleUnderline(_:)) {
                return false
            }
            
            if #available(iOS 13.0, *) {
                if action == #selector(UIResponderStandardEditActions.updateTextAttributes(conversionHandler:)) {
                    return false
                }
            }
            if #available(iOS 15.0, *) {
                if action == #selector(UIResponderStandardEditActions.pasteAndMatchStyle(_:)) ||
                    action == #selector(UIResponderStandardEditActions.pasteAndGo(_:)) ||
                    action == #selector(UIResponderStandardEditActions.pasteAndSearch(_:)) ||
                    action == #selector(UIResponderStandardEditActions.printContent(_:)) {
                    return false
                }
            }
            if #available(iOS 16.0, *) {
                if action == #selector(UIResponderStandardEditActions.useSelectionForFind(_:)) ||
                    action == #selector(UIResponderStandardEditActions.rename(_:)) ||
                    action == #selector(UIResponderStandardEditActions.duplicate(_:)) ||
                    action == #selector(UIResponderStandardEditActions.move(_:)) ||
                    action == #selector(UIResponderStandardEditActions.export(_:)) ||
                    action == #selector(UIResponderStandardEditActions.find(_:)) ||
                    action == #selector(UIResponderStandardEditActions.findAndReplace(_:)) ||
                    action == #selector(UIResponderStandardEditActions.findNext(_:)) ||
                    action == #selector(UIResponderStandardEditActions.findPrevious(_:)) ||
                    action == #selector(UIResponderStandardEditActions.useSelectionForFind(_:)) {
                    return false
                }
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

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
                action == #selector(UIResponderStandardEditActions.cut(_:)) {
                return false
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

//
//  EditableTextField.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/13/26.
//

import AppKit

final class EditableTextField: NSTextField {

    var onCommit: ((String) -> Void)?

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)

        onCommit?(stringValue)
    }
}

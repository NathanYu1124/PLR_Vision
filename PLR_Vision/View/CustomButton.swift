//
//  CustomButton.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/8.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

enum ButtonState {
    case stop
    case scan
    case select
}

protocol CustomBtnProtocal {
    func buttonPressed(_ button: CustomButton)
}

class CustomButton: NSButton {
    
    var delegate: CustomBtnProtocal!
    
    var currentState = ButtonState.select {
        didSet {
            switch self.currentState {
            case .stop:
                self.setAttributeTitle(text: "停止")
            case .scan:
               self.setAttributeTitle(text: "识别")
            case .select:
                self.setAttributeTitle(text: "选择")
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = dirtyRect.width / 2
        self.layer?.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 1).cgColor
       
    }
    
    override func mouseDown(with event: NSEvent) {
        self.layer?.backgroundColor = NSColor(red: 44 / 255, green: 43  / 255, blue: 51 / 255, alpha: 0.9).cgColor
        delegate.buttonPressed(self)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.layer?.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 1).cgColor
    }
    
    func setAttributeTitle(text: String) {
        let textColor = NSColor(red: 110, green: 110, blue: 110, alpha: 1)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let font = NSFont.systemFont(ofSize: 18)
        let attributes = [NSAttributedStringKey.foregroundColor: textColor,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle,
                          NSAttributedStringKey.font: font]
        
        
        self.attributedTitle = NSAttributedString(string: text, attributes: attributes)
    }
    
}


































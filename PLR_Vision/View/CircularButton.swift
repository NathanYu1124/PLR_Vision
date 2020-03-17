//
//  CircularButton.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/10.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class CircularButton: NSView {
    
    var button = CustomButton()
        
    var state = ButtonState.select {
        didSet{
            self.button.currentState = self.state
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = dirtyRect.width / 2
        let color = NSColor(red: 219/255, green: 235/255, blue: 246/255, alpha: 1)
        self.layer?.backgroundColor = color.cgColor
        
        button.frame = NSMakeRect(3, 3, dirtyRect.width-6,  dirtyRect.width-6)
        button.isBordered = false
        self.addSubview(button)
    }
}



























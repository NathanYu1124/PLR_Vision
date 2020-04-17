//
//  CharDetailView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/3.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class CharCell: NSView {
    
    @IBOutlet weak var charLabel: NSTextField!
    @IBOutlet weak var perLabel: NSTextField!
    @IBOutlet weak var indicatorView: NSView!
    @IBOutlet weak var indicator: NSView!
    @IBOutlet weak var bottomLine: NSView!
    @IBOutlet weak var charIconView: NSImageView!
    
    // Color
    @IBInspectable var indicatorBackgroundColor: NSColor = NSColor(cgColor: L_White)!
    @IBInspectable var indicatorColor: NSColor = NSColor(cgColor: L_Orange)!
    @IBInspectable var charColor: NSColor = NSColor(cgColor: L_White)!
    @IBInspectable var perLabelColor: NSColor = NSColor(cgColor: L_White)!
    @IBInspectable var bottomLineColor: NSColor = NSColor(cgColor: L_Gray)!
    
    @IBInspectable var hideBottomLine: Bool = false
    
    // didSet 修改百分比
    @IBInspectable var percentage: CGFloat = 50.0
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor.clear
        
        bottomLine.wantsLayer = true
        bottomLine.layer?.backgroundColor = bottomLineColor.cgColor
        bottomLine.isHidden = hideBottomLine

        indicatorView.wantsLayer = true
        indicatorView.layer?.backgroundColor = indicatorBackgroundColor.cgColor
        indicatorView.layer?.cornerRadius = indicatorView.bounds.height / 2
        
        var frame = indicator.frame
        frame = NSRect(x: 0, y: 0, width: indicatorView.frame.width * percentage / 100, height: frame.height)
        indicator.frame = frame
        
        
        indicator.wantsLayer = true
        indicator.layer?.backgroundColor = indicatorColor.cgColor
           
        charLabel.textColor = charColor
        perLabel.textColor = perLabelColor
        
    }
    
    
    func updateUI(charInfo: charInfo) {
        
        self.charLabel.stringValue = charInfo.charValue
        self.perLabel.stringValue = charInfo.charSim
        self.charIconView.image = charInfo.charImage
        
        
        var perStr = charInfo.charSim
        perStr.removeLast()
        let dPer = Double(perStr)
        percentage = CGFloat(dPer ?? 0)
                
        var frame = indicator.frame
        frame = NSRect(x: 0, y: 0, width: indicatorView.frame.width * percentage / 100, height: frame.height)
        indicator.frame = frame
        
    }
    
}

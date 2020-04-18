//
//  StateWinView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/11.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class StateWinView: NSView {
    
    // MARK: - Property
    @IBOutlet weak var platesArea: NSView!
    @IBOutlet weak var frameArea: NSView!
    @IBOutlet weak var sizeArea: NSView!
    
    @IBOutlet weak var resolutionStr: NSTextField!
    @IBOutlet weak var fpsLabel: NSTextField!
    @IBOutlet weak var blueNumLabel: NSTextField!
    @IBOutlet weak var yellowNumLabel: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor.clear
        
        platesArea.wantsLayer = true
        platesArea.layer?.cornerRadius = 15
        platesArea.layer?.backgroundColor = CGColor(red: 56 / 255, green: 65 / 255, blue: 231 / 255, alpha: 0.7)
        
        frameArea.wantsLayer = true
        frameArea.layer?.cornerRadius = 15
        frameArea.layer?.backgroundColor = CGColor(red: 51 / 255, green: 156 / 255, blue: 201 / 255, alpha: 0.7)
        
        sizeArea.wantsLayer = true
        sizeArea.layer?.cornerRadius = 15
        sizeArea.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.85)
        
    }
    
    func updateUI(resolution: String, count: (blue: Int, yellow: Int)) {
        
        resolutionStr.stringValue = resolution
        blueNumLabel.stringValue = "\(count.blue)个"
        yellowNumLabel.stringValue = "\(count.yellow)个"
    }
    
}

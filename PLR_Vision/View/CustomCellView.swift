//
//  CustomCellView.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/8.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class CustomCellView: NSTableCellView {
    
    @IBOutlet weak var iconView: NSImageView!
    
    @IBOutlet weak var textLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    
}

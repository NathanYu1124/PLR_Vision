//
//  RecordTableCell.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/16.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class RecordTableCell: NSTableCellView {
    
    @IBOutlet weak var licenseLabel: NSTextField!
    @IBOutlet weak var colorLabel: NSTextField!
    
    override var backgroundStyle: NSView.BackgroundStyle {
        willSet{
            if newValue == .dark {
                licenseLabel.textColor = NSColor(cgColor: L_Orange)
                colorLabel.textColor = NSColor(cgColor: L_Orange)
            } else {
                licenseLabel.textColor = NSColor(cgColor: L_White)
                colorLabel.textColor = NSColor(cgColor: L_White)
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        
    }
    

    
}

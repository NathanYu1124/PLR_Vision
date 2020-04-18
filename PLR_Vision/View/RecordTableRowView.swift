//
//  RecordTableRowView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/16.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class RecordTableRowView: NSTableRowView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    
    override func drawSelection(in dirtyRect: NSRect) {
        if selectionHighlightStyle != .none {
            
            let selectionRect = bounds.insetBy(dx: 2.5, dy: 2.5)
            
            // CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.85)
            NSColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.85).setFill()
            
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 25, yRadius: 25)
            selectionPath.fill()
        }
    }
    
}

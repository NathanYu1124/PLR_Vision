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
//            NSColor(calibratedRed: 61 / 255, green: 159 / 255, blue: 219 / 255, alpha: 1.0).setStroke()
            NSColor(red: 61 / 255, green: 159 / 255, blue: 219 / 255, alpha: 1.0).setFill()
            
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 25, yRadius: 25)
            selectionPath.fill()
//            selectionPath.stroke()
        }
    }
    
}

//
//  CustomRowView.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/11.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class CustomRowView: NSTableRowView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    // 改变选中背景色
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none {
            let selectionRect = NSInsetRect(self.bounds, 1, 1)
            NSColor(red: 52/255, green: 158/255, blue: 246/255, alpha: 1).setFill()
            let path = NSBezierPath(rect: selectionRect)
            path.fill()
        }
    }
    
}


























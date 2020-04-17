//
//  BottomView.swift
//  CoreGraphicDemo
//
//  Created by Nathan Yu on 2020/2/29.
//  Copyright © 2020 DimAI. All rights reserved.
//

import Cocoa

class BottomView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        
        // 绘制底部弧形
        let path = NSBezierPath()
        path.lineWidth = 1.0
        NSColor(cgColor: L_Orange)?.set()
        
        path.move(to: NSPoint(x: 0, y: 0))
        path.line(to: NSPoint(x: 0, y: 100))
        path.line(to: NSPoint(x: 395, y: 100))
        path.appendArc(withCenter: NSPoint(x: 395, y: 80), radius: 20, startAngle: 90, endAngle: 0, clockwise: true)
        path.line(to: NSPoint(x: 415, y: 55))
        path.appendArc(withCenter: NSPoint(x: 465, y: 55), radius: 50, startAngle: 180, endAngle: 0, clockwise: false)
        path.line(to: NSPoint(x: 515, y: 80))
        path.appendArc(withCenter: NSPoint(x: 535, y: 80), radius: 20, startAngle: 180, endAngle: 90, clockwise: true)
        path.line(to: NSPoint(x: 930, y: 100))
        path.line(to: NSPoint(x: 930, y: 0))
        path.line(to: NSPoint(x: 0, y: 0))
        
        path.fill()
        
    }
    
}

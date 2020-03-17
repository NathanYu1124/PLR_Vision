//
//  WindowController.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/7.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // 设置窗口位置
        if let window = window, let screen = window.screen {
            
            window.backgroundColor = NSColor.clear
        
            let windowRect = screen.visibleFrame
            let frame = window.frame

            // 窗口居中显示
            let originX = windowRect.width / 2 - frame.width / 2
            let originY = windowRect.height / 2 - frame.height / 2
            window.setFrameOrigin(NSPoint(x: originX, y: originY))
        }
    }

}

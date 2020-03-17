//
//  HomeWindowController.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/2/27.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class HomeWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        setUI()
    }

    func setUI() {
        
        window?.setFrame(NSRect(x: 0, y: 0, width: HomeWidth, height: HomeHeight), display: true)

        // 窗口透明
        window?.isOpaque = false
        window?.backgroundColor = NSColor.clear

        
        // 窗口圆角
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.backgroundColor = CGColor.clear
        window?.contentView?.layer?.cornerRadius = 20.0
        window?.contentView?.layer?.masksToBounds = true
    }
    
    
}

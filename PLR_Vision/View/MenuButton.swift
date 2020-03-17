//
//  MenuButton.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/2/28.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa



class MenuButton: NSButton {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func mouseDown(with event: NSEvent) {
        
        if self.state == .on {      // 状态为on时拦截点击事件
            return
        }
        self.performClick(self)     // 执行按钮的点击事件
    }
    
}

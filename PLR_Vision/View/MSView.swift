//
//  MSView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/2/29.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class MSView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    

    // 阻止点击事件向上传递到父视图
    override func mouseDown(with event: NSEvent) {
        
    }
    
}

//
//  WelcomeView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/16.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class WelcomeView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.backgroundColor = L_Orange
    }
    
}

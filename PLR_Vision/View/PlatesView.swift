//
//  PlatesView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/15.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class PlatesView: NSView {
    
    @IBOutlet weak var yellowLabel: NSTextField!
    @IBOutlet weak var bludeLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
    }
    
    func updateUI(plateModels: [PlateInfoModel]) {
        
        var yellowNum = 0
        var blueNum = 0
        for model in plateModels {
            if model.plateColor == "蓝牌" {
                blueNum += 1
            } else {
                yellowNum += 1
            }
        }
        
        yellowLabel.stringValue = "\(yellowNum)个"
        bludeLabel.stringValue = "\(blueNum)个"
    }
    
}

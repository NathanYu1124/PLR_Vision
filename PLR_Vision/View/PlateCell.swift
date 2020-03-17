//
//  PlateCell.swift
//  PLR_Vision
//
//  Created by NathanYu on 2018/5/8.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class PlateCell: NSTableCellView {
    
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var textLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    
    func updateUI(color: String, license: String) {
        
        if color == "黄牌" {
            self.iconImageView.image = NSImage(named: NSImage.Name(rawValue: "plate_yellow"))
        } else {
            self.iconImageView.image = NSImage(named: NSImage.Name(rawValue: "plate_blue"))
        }
        
        textLabel.stringValue = license
    }
    
   
}

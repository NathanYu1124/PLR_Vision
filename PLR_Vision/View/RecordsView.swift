//
//  RecordsView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/16.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class RecordsView: NSView {
    
    @IBOutlet weak var recordsLabel: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func updateUI(records: Int) {
        recordsLabel.stringValue = "\(records)个"
    }
    
}

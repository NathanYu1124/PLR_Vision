//
//  TimeView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/16.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class TimeView: NSView {
    
    @IBOutlet weak var timeLabel: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func updateUI(sTime: Date, eTime: Date) {
        let diff = Calendar.current.compare(eTime, to: sTime, toGranularity: .second)
        let duration = diff.rawValue
        timeLabel.stringValue = "\(duration) S"
    }
    
}

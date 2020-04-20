//
//  VideoWinView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/12.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class VideoWinView: NSView {
    
    @IBOutlet weak var stateBar: NSView!
    @IBOutlet weak var startLabel: NSTextField!
    @IBOutlet weak var endLabel: NSTextField!
    @IBOutlet weak var videoView: NSImageView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var infoView: NSView!
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.cornerRadius = 20
        self.layer?.backgroundColor = L_Gray
        
        stateBar.wantsLayer = true
        stateBar.layer?.cornerRadius = 10
        stateBar.layer?.backgroundColor = CGColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.15)
        
        videoView.wantsLayer = true
        videoView.layer?.cornerRadius = 15
        
    }
    
    
    func updateUI(frame: FrameModel) {
        
        videoView.image = frame.frameImage
        startLabel.stringValue = frame.currentLoc
        endLabel.stringValue = frame.duration
        progressBar.doubleValue = frame.progress * 100
    }
    
    func showFinishView() {
        
    }
    
    
}

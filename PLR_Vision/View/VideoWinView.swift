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
    @IBOutlet weak var finishView: NSView!
    
    var shouldShowFinView = false

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.cornerRadius = 20
        self.layer?.backgroundColor = L_Gray
        
        finishView.wantsLayer = true
        finishView.layer?.cornerRadius = 15
        finishView.layer?.backgroundColor = CGColor(red: 65 / 255, green: 103 / 255, blue: 98 / 255, alpha: 1)
        finishView.alphaValue = shouldShowFinView ? 1 : 0
        
        stateBar.wantsLayer = true
        stateBar.layer?.cornerRadius = 10
        stateBar.layer?.backgroundColor = CGColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.15)
        
        videoView.wantsLayer = true
        videoView.layer?.cornerRadius = 15
    }
    
    func updateUI(frame: FrameModel) {
        
        print("Debug: VideoWinView -> updateUI")
        
        videoView.image = frame.frameImage
        startLabel.stringValue = frame.currentLoc
        endLabel.stringValue = frame.duration
        progressBar.doubleValue = frame.progress * 100
      
        print("Progress: \(progressBar.doubleValue)")
    }
    
    // 当前视频处理完毕时显示
    func showFinishView() {
        
        shouldShowFinView = true
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.1
            
            finishView.animator().alphaValue = 1
        })
    }
    
    // 还原为初始状态
    func refreshVideoWinView() {
        
        shouldShowFinView = false
        progressBar.doubleValue = 0
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.1
            
            finishView.animator().alphaValue = 0
        })
    }
    
}

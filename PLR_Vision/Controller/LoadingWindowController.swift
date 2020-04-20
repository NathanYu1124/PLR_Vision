//
//  LoadingWindowController.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/10.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class LoadingWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.cornerRadius = 15.0
        
        window!.backgroundColor = NSColor.clear
        window!.center()
    
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {

            let homeWC = self.storyboard!.instantiateController(withIdentifier: "HomeWindowController") as! HomeWindowController

            //  退出加载窗口
            self.window?.orderOut(nil)

            // 显示主窗口
            homeWC.window?.makeKeyAndOrderFront(nil)
            homeWC.window?.center()

        }
        
        
    }
    
}

























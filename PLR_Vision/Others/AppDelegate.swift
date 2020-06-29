//
//  AppDelegate.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 04/04/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var homeVC: HomeViewController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
       
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    
//    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
//        // 当前是否在进行视频处理
//        if !homeVC.videoHasFinished {
//            let flag = homeVC.showStopAlert()
//            
//            return (flag == true) ? .terminateNow : .terminateCancel
//        }
//        
//        return .terminateNow
//    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}


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

//    // 创建状态栏
//    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
       
//        // 设置状态栏Item
//        if let button = statusItem.button {
//            button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
//            button.action = #selector(showPopMenu(_:))
//        }
    }
    
    @objc func showPopMenu(_ sender: Any?) {
        
        
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }


}


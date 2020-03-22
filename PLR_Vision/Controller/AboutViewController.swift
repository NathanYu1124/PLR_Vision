//
//  AboutViewController.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/11.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {

    @IBOutlet weak var detailView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.wantsLayer = true
        // CGColor(red: 249 / 255, green: 241 / 255, blue: 233 / 255, alpha: 0.6)
        view.layer?.backgroundColor = CGColor.clear
        
        detailView.wantsLayer = true
        detailView.layer?.backgroundColor = L_Yellow
        detailView.layer?.cornerRadius = 15.0
    }
    
    @IBAction func closeButtonPressed(_ sender: NSButton) {

        self.view.removeFromSuperview()
    }
    
    // 项目地址
    @IBAction func showProjectPage(_ sender: NSButton) {
        let url = URL(string: "https://github.com/NathanYu1124/PLR_Vision")!
        NSWorkspace.shared.open(url)
    }
    
    // 关于我们
    @IBAction func showUsPage(_ sender: NSButton) {
        let url = URL(string: "https://github.com/NathanYu1124/PLR_Vision")!
        NSWorkspace.shared.open(url)
    }
    
    // 帮助支持
    @IBAction func showHelpPage(_ sender: NSButton) {
        let url = URL(string: "https://github.com/NathanYu1124/PLR_Vision")!
        NSWorkspace.shared.open(url)
    }
    
    // 更新日志
    @IBAction func showLogPage(_ sender: NSButton) {
        let url = URL(string: "https://github.com/NathanYu1124/PLR_Vision/releases")!
        NSWorkspace.shared.open(url)
    }
}

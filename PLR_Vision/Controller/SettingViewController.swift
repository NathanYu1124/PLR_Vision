//
//  SettingViewController.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/2.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor(red: 249 / 255, green: 60 / 255, blue: 26 / 255, alpha: 0.8)
    }
    
}

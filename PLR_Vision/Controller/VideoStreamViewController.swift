//
//  VideoStreamViewController.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/2.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class VideoStreamViewController: NSViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor(red: 56 / 255, green: 65 / 255, blue: 231 / 255, alpha: 0.6)
        
    }
    
    
    
}

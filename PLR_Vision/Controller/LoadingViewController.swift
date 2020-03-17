//
//  LoadingViewController.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/10.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class LoadingViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getModelPath()
    }
    
    // 获取模型地址
   private func getModelPath() {
        
        SVM_MODEL_PATH = Bundle.main.path(forResource: "svm", ofType: "xml")
        CNN_CHAR_MODEL_PATH = Bundle.main.path(forResource: "CNN_CHAR_MODEL", ofType: "md")
        CNN_ZH_MODEL_PATH = Bundle.main.path(forResource: "CNN_ZH63_MODEL", ofType: "md")
        CACHE_PATH = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
    }
    
}

//
//  DetailView.swift
//  PLR_Vision
//
//  Created by NathanYu on 2018/5/17.
//  Copyright © 2018年 NathanYu. All rights reserved.
//

import Cocoa

protocol DetailViewProtocal {
    func backToMainView(_ detailView: DetailView)
    func playPlateSound(_ detailView: DetailView, license: String, sender: NSButton)
}

class DetailView: NSView {
    
    var delegate: DetailViewProtocal?
    
    @IBOutlet weak var plateImageView: NSImageView!
    @IBOutlet weak var licenseLabel: NSTextField!
    @IBOutlet weak var licenseColorLabel: NSTextField!
    @IBOutlet weak var voiceButton: NSButton!
    
    // MARK: - 字符控件绑定tag值
    // charImage: 1001, 2001....7001   charValue: 1002, 2002.....7002    sim: 1003, 2003......7003
    @IBOutlet weak var charImage1: NSImageView!
    @IBOutlet weak var charImage2: NSImageView!
    @IBOutlet weak var charImage3: NSImageView!
    @IBOutlet weak var charImage4: NSImageView!
    @IBOutlet weak var charImage5: NSImageView!
    @IBOutlet weak var charImage6: NSImageView!
    @IBOutlet weak var charImage7: NSImageView!
    
    @IBOutlet weak var charValue1: NSTextField!
    @IBOutlet weak var charValue2: NSTextField!
    @IBOutlet weak var charValue3: NSTextField!
    @IBOutlet weak var charValue4: NSTextField!
    @IBOutlet weak var charValue5: NSTextField!
    @IBOutlet weak var charValue6: NSTextField!
    @IBOutlet weak var charValue7: NSTextField!
    
    @IBOutlet weak var sim1: NSTextField!
    @IBOutlet weak var sim2: NSTextField!
    @IBOutlet weak var sim3: NSTextField!
    @IBOutlet weak var sim4: NSTextField!
    @IBOutlet weak var sim5: NSTextField!
    @IBOutlet weak var sim6: NSTextField!
    @IBOutlet weak var sim7: NSTextField!
    
    var plateModel: PlateInfoModel?
    
    
    // MARK: - func
    class func creatViewFromNib() -> DetailView? {
        let nib = NSNib(nibNamed: NSNib.Name("DetailView"), bundle: nil)!
        var topLevelObjects: NSArray?
        var view: DetailView?
        if nib.instantiate(withOwner: nil, topLevelObjects: &topLevelObjects) {
            for topObject in topLevelObjects! {
                if topObject is DetailView {
                    view = topObject as? DetailView
                    view?.wantsLayer = true
                    view?.layer?.backgroundColor = NSColor(red: 44 / 255, green: 43  / 255, blue: 51 / 255, alpha: 1).cgColor
                    break
                }
            }
        }
        
        return view
    }
    
    // 更新UI
    func layoutUI(plateModel: PlateInfoModel) {
        self.plateModel = plateModel
        
        // 车牌图片
        self.plateImageView.image = plateModel.plateImage
        
        // 车牌号
        self.licenseLabel.stringValue = plateModel.plateLicense
        
        // 颜色
        self.licenseColorLabel.stringValue = plateModel.plateColor
        
        // 字符详情
        let charsInfo = plateModel.charsArray!
        for i in 1...7 {
            let baseTag = i * 1000
            
            // 根据tag值获取控件
            let charImageView = self.viewWithTag(baseTag + 1) as! NSImageView
            let charValue = self.viewWithTag(baseTag + 2) as! NSTextField
            let charSim = self.viewWithTag(baseTag + 3) as! NSTextField
            
            charImageView.image = charsInfo[i - 1].charImage
            charValue.stringValue = charsInfo[i - 1].charValue
            charSim.stringValue = charsInfo[i - 1].charSim
        }
        
        // 语音播报
        self.delegate?.playPlateSound(self, license: plateModel.plateLicense, sender: self.voiceButton)
    }

    // 退出详情视图
    @IBAction func backButtonPressed(_ sender: NSButton) {
        self.delegate?.backToMainView(self)
    }
    
    // 语音播报车牌号
    @IBAction func voiceButtonPressed(_ sender: NSButton) {
        
        let license = self.plateModel!.plateLicense
        
        self.delegate?.playPlateSound(self, license: license!, sender: sender)
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
    }
    
}

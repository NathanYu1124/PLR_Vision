//
//  PlateDetailView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/15.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class PlateDetailView: NSView {
    
    @IBOutlet weak var plateView: NSImageView!
    @IBOutlet weak var plateLabel: NSTextField!
    @IBOutlet weak var colorLabel: NSTextField!
    @IBOutlet weak var provinceLabel: NSTextField!
    

    @IBOutlet var contentView: NSView!
    
    
    
    // MARK: - init
    
    // 代码创建
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "PlateDetailView"), bundle: Bundle(for: type(of: self)))
        nib?.instantiate(withOwner: self, topLevelObjects: nil)
        
        contentView.wantsLayer = true
        
        // 布局
        let contentConstraints = contentView.constraints
        contentView.subviews.forEach({ addSubview($0) })
        
        for constraint in contentConstraints {
            let firstItem = (constraint.firstItem as? NSView == contentView) ? self : constraint.firstItem
            let secondItem = (constraint.secondItem as? NSView == contentView) ? self : constraint.secondItem
            addConstraint(NSLayoutConstraint(item: firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
        }
        
                       
        addSubview(contentView)
    }
    
    // 从 SotryBoard 创建
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "PlateDetailView"), bundle: Bundle(for: type(of: self)))
        nib?.instantiate(withOwner: self, topLevelObjects: nil)
        
        contentView.wantsLayer = true
        
        // 布局
        let contentConstraints = contentView.constraints
        contentView.subviews.forEach({ addSubview($0) })
        
        for constraint in contentConstraints {
            let firstItem = (constraint.firstItem as? NSView == contentView) ? self : constraint.firstItem
            let secondItem = (constraint.secondItem as? NSView == contentView) ? self : constraint.secondItem
            addConstraint(NSLayoutConstraint(item: firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
        }
                
        addSubview(contentView)
    }
    
    // MARK: - func
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.4)
        self.layer?.cornerRadius = 15
    }
    
    func updateUI(plateModel: PlateInfoModel) {
        plateView.image = plateModel.plateImage
        plateLabel.stringValue = plateModel.plateLicense
        colorLabel.stringValue = plateModel.plateColor
        let province = String(plateModel.plateLicense.first!)
        provinceLabel.stringValue = ProvinceDict[province]!
    }
    
    
    @IBAction func playLicenseSound(_ sender: NSButton) {
        
        if !AudioTool.isPlaying() {
            AudioTool.playPlateSound(license: plateLabel.stringValue as NSString)
        }
    }
    
}

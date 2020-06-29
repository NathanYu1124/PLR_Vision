//
//  PlateDetailView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/15.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

enum PlateDetailType {
    case video
    case image
}

class PlateDetailView: NSView {
    
    @IBOutlet weak var imgPlateView: NSImageView!
    @IBOutlet weak var plateLabel: NSTextField!
    @IBOutlet weak var colorLabel: NSTextField!
    @IBOutlet weak var provinceLabel: NSTextField!
    @IBOutlet weak var maskView: NSView!
    @IBOutlet weak var infoView: NSView!
    @IBOutlet weak var loadingImageView: NSImageView!
    @IBOutlet weak var imageStateView: NSView!
    @IBOutlet weak var soundStateView: NSView!
    
    @IBOutlet weak var plateTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var plateBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var contentView: NSView!
    
    var isRotating = false
    var model: PlateInfoModel!
    
    
    // MARK: - init
    
    // 代码创建
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        print("Debug: PlateDetailView -> init(rect)")
        
        let nib = NSNib(nibNamed: "PlateDetailView", bundle: Bundle(for: type(of: self)))
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
        
        print("Debug: PlateDetailView -> init(coder)")
        
        let nib = NSNib(nibNamed: "PlateDetailView", bundle: Bundle(for: type(of: self)))
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
        
//        print("Debug: PlateDetailView -> draw")

        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.4)
        self.layer?.cornerRadius = 15
        
        infoView.isHidden = (model == nil)
        maskView.isHidden = (model != nil)
        
        maskView.wantsLayer = true
        maskView.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.4)
        maskView.layer?.cornerRadius = 15
        
        if model == nil {
            addLoadingRotateAnim()
        }
        
    }
    
    
    func updateUI(plateModel: PlateInfoModel, type: PlateDetailType) {
        
        model = plateModel
            
        soundStateView.isHidden = (type == .image) ? false : true
        plateTopConstraint.constant = (type == .image) ? 2 : 20
        plateBottomConstraint.constant = (type == .image) ? -2 : -20
        
        print("Debug: PlateDetailView -> updateUI")
        removeMaskAndRotateAnim()
        
        imgPlateView.image = plateModel.plateImage
        
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
    
    // 加载图标旋转动画
    func addLoadingRotateAnim() {
        
        if !isRotating {
            isRotating = true
            
            NSAnimationContext.runAnimationGroup({ (context) in
                let rotateAnim = CABasicAnimation(keyPath: "transform.rotation")
                rotateAnim.toValue = CGFloat(-Double.pi * 2.0)
                rotateAnim.repeatCount = HUGE
                rotateAnim.duration = 1.0
                
                loadingImageView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                loadingImageView.layer?.position = loadingImageView.center
                loadingImageView.layer?.add(rotateAnim, forKey: nil)

            })
        }
    }
    
    func removeMaskAndRotateAnim() {
        loadingImageView.layer?.removeAllAnimations()
        isRotating = false
        maskView.isHidden = true
        infoView.isHidden = false
    }
    
}

extension NSView {
    var center: CGPoint {
        get {
            return CGPoint(x: NSMidX(self.frame), y: NSMidY(self.frame))
        }
    }
}

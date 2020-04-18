//
//  WelcomeView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/16.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

enum MenuType {
    case image
    case video
}

class WelcomeView: NSView {
    
    @IBOutlet weak var logoImageView: NSImageView!
    @IBOutlet weak var typeLable: NSTextField!
    @IBOutlet weak var noticeLabel: NSTextField!
    
    @IBOutlet var contentView: NSView!
    
    // 背景颜色
    var backgroundColor = L_Orange {
        didSet {
            self.wantsLayer = true
            self.layer?.backgroundColor = backgroundColor
        }
    }
    
    
    // MARK: - init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "WelcomeView"), bundle: Bundle(for: type(of: self)))
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
    }
    
    // 设置欢迎内容
    func setContentType(type: MenuType) {
        switch type {
        case .image:
            typeLable.stringValue = "PLR Vision可识别的图像格式: png, jpg"
            noticeLabel.stringValue = "注意: 图片路径中不能含有中文及空格"
            self.backgroundColor = CGColor(red: 252 / 255, green: 124 / 255, blue: 91 / 255, alpha: 1)
        case .video:
            typeLable.stringValue = "PLR Vision可识别的视频格式: mp4"
            noticeLabel.stringValue = "注意: 视频路径中不能含有中文及空格"
            self.backgroundColor = CGColor(red: 138 / 255, green: 147 / 255, blue: 234 / 255, alpha: 1)
        }
    }
    
}

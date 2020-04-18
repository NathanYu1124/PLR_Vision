//
//  BottomView.swift
//  CoreGraphicDemo
//
//  Created by Nathan Yu on 2020/2/29.
//  Copyright © 2020 DimAI. All rights reserved.
//

import Cocoa

protocol BottomViewProtocol {
    func buttonPressed(_ bottomView: BottomView, sender: NSButton)
}

class BottomView: NSView {
    
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var shadowView: NSView!
    @IBOutlet weak var circleButton: NSButton!
        
    var maskLayer: CAShapeLayer!
    let cPathInitial = NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 90, height: 90))
    let cPathFinal = NSBezierPath(ovalIn: NSRect(x: 5, y: 5, width: 80, height: 80))
  
    var backgroundColor = L_White {
        didSet {
            self.wantsLayer = true
            self.layer?.backgroundColor = backgroundColor
        }
    }
    
    var delegate: BottomViewProtocol?
    
    
    // MARK: - init
    // 从 StoryBoard 创建
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "BottomView"), bundle: Bundle(for: type(of: self)))
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
        
        // 绘制底部弧形
        let path = NSBezierPath()
        path.lineWidth = 1.0
        NSColor(cgColor: L_Orange)?.set()
        
        path.move(to: NSPoint(x: 0, y: 0))
        path.line(to: NSPoint(x: 0, y: 100))
        path.line(to: NSPoint(x: 395, y: 100))
        path.appendArc(withCenter: NSPoint(x: 395, y: 80), radius: 20, startAngle: 90, endAngle: 0, clockwise: true)
        path.line(to: NSPoint(x: 415, y: 55))
        path.appendArc(withCenter: NSPoint(x: 465, y: 55), radius: 50, startAngle: 180, endAngle: 0, clockwise: false)
        path.line(to: NSPoint(x: 515, y: 80))
        path.appendArc(withCenter: NSPoint(x: 535, y: 80), radius: 20, startAngle: 180, endAngle: 90, clockwise: true)
        path.line(to: NSPoint(x: 930, y: 100))
        path.line(to: NSPoint(x: 930, y: 0))
        path.line(to: NSPoint(x: 0, y: 0))
        path.fill()
        
        circleButton.wantsLayer = true
        circleButton.layer?.cornerRadius = circleButton.frame.width / 2
        circleButton.layer?.backgroundColor = L_Yellow
        
        shadowView.wantsLayer = true
        shadowView.layer?.cornerRadius = shadowView.frame.width / 2
        shadowView.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.7)
        
        maskLayer = CAShapeLayer()
        maskLayer.path = cPathInitial.cgPath
        shadowView.layer?.mask = maskLayer
    }
    
    
    // 设置样式类型
    func setViewType(type: MenuType) {
                
        switch type {
        case .image:
            
            self.backgroundColor = CGColor(red: 252 / 255, green: 124 / 255, blue: 91 / 255, alpha: 1)
        case .video:
            
            self.backgroundColor = CGColor(red: 138 / 255, green: 147 / 255, blue: 234 / 255, alpha: 1)
        }
    }
    
    
    @IBAction func buttonPressed(_ sender: NSButton) {
    
        NSAnimationContext.runAnimationGroup({ (context) in
            // 点击动画
            let circleAnimation = CABasicAnimation(keyPath: "path")
            circleAnimation.fromValue = cPathInitial.cgPath
            circleAnimation.toValue = cPathFinal.cgPath
            circleAnimation.duration = 0.15
            maskLayer.add(circleAnimation, forKey: "path")
        }) {
            self.delegate?.buttonPressed(self, sender: sender)
        }
    }
    
    

    
    
    
}

//
//  RecordDetailView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/17.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

protocol RecordDetailViewProtocol {
    func hideAnimationFinished(_ detailView: RecordDetailView)
}

class RecordDetailView: NSView {
    
    // MARK: - animation property
    var maskLayer: CAShapeLayer!
    var circlePathInitial: NSBezierPath!
    var circlePathFinal: NSBezierPath!
    var rectInitial: NSRect!
    let animTime: CFTimeInterval = 0.35
    var delegate: RecordDetailViewProtocol?
    
    // MARK: - UI property
    @IBOutlet var contentView: NSView!
    
    @IBOutlet weak var charsView: CharsView!
    @IBOutlet weak var infoView: NSView!
    @IBOutlet weak var backView: NSView!
    @IBOutlet weak var plateImageView: NSImageView!
    @IBOutlet weak var licenseLabel: NSTextField!
    @IBOutlet weak var colorLabel: NSTextField!
    
    
    var plateModel: PlateInfoModel!
    
    
    // MARK: - init
    // 代码创建
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "RecordDetailView"), bundle: Bundle(for: type(of: self)))
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
        
        // 初始化
        setup()
    }
    
    // 从 StoryBoard 创建
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "RecordDetailView"), bundle: Bundle(for: type(of: self)))
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
        
        // 初始化
        setup()
    }
    
    // MARK: - func
    private func setup() {
        
        self.wantsLayer = true
        self.layer?.cornerRadius = 20
        self.layer?.backgroundColor = L_White
        
        backView.wantsLayer = true
        backView.layer?.cornerRadius = 20
        backView.layer?.backgroundColor = CGColor(red: 174 / 255, green: 161 / 255, blue: 174 / 255, alpha: 1.0)
        
        infoView.wantsLayer = true
        infoView.layer?.cornerRadius = 20
        infoView.layer?.backgroundColor = L_Yellow
        
        charsView.backgroundColor = CGColor(red: 37 / 255, green: 150 / 255, blue: 172 / 255, alpha: 0.9)

        rectInitial = NSRect(x: 0, y: 0, width: 1, height: 1)
        maskLayer = CAShapeLayer()
        self.layer?.mask = maskLayer
    }
    
    func updateUI(model: PlateInfoModel) {
        
        plateImageView.image = model.plateImage
        licenseLabel.stringValue = model.plateLicense
        colorLabel.stringValue = model.plateColor
        
        charsView.updateUI(charsArray: model.charsArray)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    @IBAction func playLicenseSound(_ sender: Any) {
        
        if !AudioTool.isPlaying() {
            AudioTool.playPlateSound(license: licenseLabel.stringValue as NSString)
        }
    }
    
    // MARK: - Circle Animation
    // view显示动画
    func showCircleAnimation(model: PlateInfoModel) {
        
        // 填充数据
        updateUI(model: model)
        
        // 移除之前的动画
        maskLayer.removeAnimation(forKey: "path")
        
        let len_1 = self.frame.width
        let len_2 = self.frame.height
        let radius = sqrt(len_1 * len_1 + len_2 * len_2)
        
        circlePathInitial = NSBezierPath(ovalIn: rectInitial)
        circlePathFinal = NSBezierPath(ovalIn: NSInsetRect(rectInitial, -radius, -radius))
        maskLayer.path = circlePathFinal.cgPath
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circlePathInitial.cgPath
        maskLayerAnimation.toValue = circlePathFinal.cgPath
        maskLayerAnimation.duration = animTime
        
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    // view隐藏动画
    @objc func hideCircleAnimation() {

        // 移除之前的动画
        maskLayer.removeAnimation(forKey: "path")
        
        let len_1 = self.frame.width
        let len_2 = self.frame.height
        let radius = sqrt(len_1 * len_1 + len_2 * len_2)
        
        circlePathInitial = NSBezierPath(ovalIn: NSInsetRect(rectInitial, -radius, -radius))
        circlePathFinal = NSBezierPath(ovalIn: rectInitial)
        maskLayer.path = circlePathFinal.cgPath
        
        NSAnimationContext.runAnimationGroup({ (context) in
            
            let maskLayerAnimation = CABasicAnimation(keyPath: "path")
            maskLayerAnimation.fromValue = circlePathInitial.cgPath
            maskLayerAnimation.toValue = circlePathFinal.cgPath
            maskLayerAnimation.duration = animTime
            maskLayer.add(maskLayerAnimation, forKey: "path")
            
        }) {
            // 动画完成后通知父视图
            self.delegate?.hideAnimationFinished(self)
        }
    }
    
    
    @IBAction func dismissView(_ sender: Any) {
        
        hideCircleAnimation()
    }
    
}


// MARK: - mouse handle events
extension RecordDetailView {
    
    // 阻止点击事件向上传递到父视图
    override func mouseDown(with event: NSEvent) {
      
    }
}


// MARK: - NSBezierPath extension
extension NSBezierPath {

    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement:
                path.move(to: points[0])
            case .lineToBezierPathElement:
                path.addLine(to: points[0])
            case .curveToBezierPathElement:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePathBezierPathElement:
                path.closeSubpath()
            }
        }

        return path
    }
}

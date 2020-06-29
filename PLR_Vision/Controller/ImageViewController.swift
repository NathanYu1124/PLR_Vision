//
//  ImageViewController.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/2/29.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa
import AVFoundation

class ImageViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var imageAreaView: NSView!
    @IBOutlet weak var platesView: PlatesView!
    @IBOutlet weak var plateDetailView: PlateDetailView!
    @IBOutlet weak var bottomView: BottomView!
    @IBOutlet weak var changeView: NSView!
    @IBOutlet weak var charsView: CharsView!
    @IBOutlet weak var welcomeView: WelcomeView!
    @IBOutlet weak var timeView: TimeView!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var recordsView: RecordsView!
    
    private var preImage: NSImage!
    private var dictModels: [PlateInfoModel]!
    private var plateIndex: Int = 0
    private var records: Int = 0
        
        
    // MARK: - View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // 初始显示欢迎页面
//        contentView.isHidden = true
        
        welcomeView.setContentType(type: .image)
        
        bottomView.delegate = self
        bottomView.setViewType(type: .image)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        setupUI()
    }
    
    func setupUI() {
        
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 20
        
        imageAreaView.wantsLayer = true
        imageAreaView.layer?.cornerRadius = 20
        imageAreaView.layer?.backgroundColor = L_Gray
        
        changeView.wantsLayer = true
        changeView.layer?.cornerRadius = 20
        changeView.layer?.backgroundColor = CGColor(red: 249 / 255, green: 60 / 255, blue: 26 / 255, alpha: 0.6)
        
        platesView.wantsLayer = true
        platesView.layer?.cornerRadius = 20
        platesView.layer?.backgroundColor = CGColor(red: 56 / 255, green: 65 / 255, blue: 231 / 255, alpha: 0.7)
        
        timeView.wantsLayer = true
        timeView.layer?.cornerRadius = 20
        timeView.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.7)
        
        recordsView.wantsLayer = true
        recordsView.layer?.cornerRadius = 20
        recordsView.layer?.backgroundColor = CGColor(red: 51 / 255, green: 156 / 255, blue: 201 / 255, alpha: 0.7)
    }
    
    // 识别选中的图片
    func analyseImage(sender: NSButton) {
        
        // 禁止交互
        sender.isEnabled = false
        
        plateIndex = 0
        
        // 文件选择
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.allowedFileTypes = ["jpg","png","jpeg"]
        panel.begin { (result) in
            if result == .OK {
                if let url = panel.url {
                    
                    // 获取选中图片的绝对路径
                    var path = url.absoluteString
                    let range = path.startIndex...path.index(path.startIndex, offsetBy: 6)
                    path.removeSubrange(range)
                    
                    let startTime = Date()
                    
                    // 后台执行
                    DispatchQueue.global().async {
                        if let dict = ImageConverter.getPlateLicense(path, svmPath: SVM_MODEL_PATH, charPath: CNN_CHAR_MODEL_PATH, zhPath: CNN_ZH_MODEL_PATH, outPath: CACHE_PATH)
                        {
                            if dict.count == 0 {   // 图片路径中有空格或汉字: 无法读取图片
                                DispatchQueue.main.async {
                                    self.showAlert()
                                }
                            } else {
                                
                                self.records += 1
                                // 识别信息 字典转模型
                                self.dictModels = PlateInfoModel.getModels(dict: dict)
                                let endTime = Date()
                                
                                // 主线程更新UI
                                DispatchQueue.main.async {
                                    
                                    // 更换绘制过的图片
                                    let imgPath = CACHE_PATH + "/drawcar.jpg";
                                    if let image = NSImage(byReferencingFile: imgPath) {
                                        self.imageView.image = image
                                        self.updateUI(plateModel: self.dictModels[self.plateIndex])
                                        self.timeView.updateUI(sTime: startTime, eTime: endTime)
                                        self.recordsView.updateUI(records: self.records)
                                    } else {
                                        print("can't load drawed image!")
                                    }
                                    
                                    // 切换详情界面
                                    if !self.welcomeView.isHidden {
                                        // 动画
                                        self.showContentViewAnimation()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            sender.isEnabled = true
        }
    }
    
    // 动画
    func showContentViewAnimation() {
                
        NSAnimationContext.runAnimationGroup({ (context) in
            let maskLayer = CAShapeLayer()
            let circlePathInitial = NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 930, height: 930))
            let circlePathFinal = NSBezierPath(ovalIn: NSRect(x: 465, y: 300, width: 1, height: 1))
            maskLayer.path = circlePathFinal.cgPath
            welcomeView.layer?.mask = maskLayer
            
            let anim = CABasicAnimation(keyPath: "path")
            anim.duration = 0.2
            anim.fromValue = circlePathInitial.cgPath
            anim.toValue = circlePathFinal.cgPath
            maskLayer.add(anim, forKey: "path")
            
            bottomView.animator().layer?.backgroundColor = CGColor.clear
            
        }) {
            self.welcomeView.isHidden = true
        }
    }
    
    // 路径有误时处理
    private func showAlert() {
        // alert提醒
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.icon = NSImage(named: "AppIcon")
        alert.addButton(withTitle: "退出")
        alert.messageText = "未能成功读取图片!"
        alert.informativeText = "请检查图片路径中是否有空格或汉字, 若有则无法正常加载图片!"
        alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { (modalResponse) in
          
        if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
               
           }
       }
    }
    
    // 更新UI
    private func updateUI(plateModel: PlateInfoModel) {
        charsView.updateUI(charsArray: plateModel.charsArray)
        platesView.updateUI(plateModels: dictModels)
        plateDetailView.updateUI(plateModel: plateModel, type: .image)
    }
    
    @IBAction func slideToNextPlate(_ sender: NSButton) {
        if plateIndex + 1 < dictModels.count {
            plateIndex += 1
            updateUI(plateModel: dictModels[plateIndex])
        }
    }
    
    
    @IBAction func slideToPrePlate(_ sender: NSButton) {
        if plateIndex - 1 >= 0 {
            plateIndex -= 1
            updateUI(plateModel: dictModels[plateIndex])
        }
    }
}

// MARK: - BottomViewProtocol
extension ImageViewController: BottomViewProtocol {
    
    func buttonPressed(_ bottomView: BottomView, sender: NSButton) {
        analyseImage(sender: sender)
    }
    
    
}

//
//  VideoStreamViewController.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/2.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class VideoStreamViewController: NSViewController {

    
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var videoArea: VideoWinView!
    @IBOutlet weak var stateArea: StateWinView!
    @IBOutlet weak var recordArea: RecordWinView!
    @IBOutlet weak var showArea: ShowWinView!
    @IBOutlet weak var fpsLabel: NSTextField!
    @IBOutlet weak var welcomeView: WelcomeView!
    @IBOutlet weak var bottomView: BottomView!
    
    var recordDetailView: RecordDetailView!
    var timer: Timer!
    var fps = 0
    var count = 0
    var frameModel: FrameModel!
    var plateModels = [PlateInfoModel]()
    var isAnalysingVideo = false        // 是否正在处理视频
    
    // 完成提示
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
    }
    
    func setupUI() {
        
        
        recordArea.delegate = self
        welcomeView.setContentType(type: .video)
        
        bottomView.delegate = self
        bottomView.setViewType(type: .video)
    }
    
    // 处理视频
    func analyseVideo(sender: NSButton) {
        
        if !isAnalysingVideo {
            isAnalysingVideo = true
            
            // 禁止交互
            sender.isEnabled = false
            
            // 视频文件选择
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            panel.canCreateDirectories = false
            panel.allowedFileTypes = ["mp4"]
            panel.begin { (result) in
                if result == .OK {
                    if let url = panel.url {
                        
                        var path = url.absoluteString
                        let range = path.startIndex...path.index(path.startIndex, offsetBy: 6)
                        path.removeSubrange(range)
                        
                        // 后台处理视频
                        DispatchQueue.global().async {
                            let flag = ImageConverter.startAnalyseVideo(path, svmPath: SVM_MODEL_PATH, charPath: CNN_CHAR_MODEL_PATH, zhPath: CNN_ZH_MODEL_PATH, outPath: CACHE_PATH)
                            if flag == false {      // 未能成功加载视频
                                self.isAnalysingVideo = false
                                DispatchQueue.main.async {
                                    self.showErrorAlert()
                                }
                                return
                            }
                        }
                        
                        // 主线程刷新UI
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                            
                            if !self.welcomeView.isHidden {
                                self.showContentViewAnimation()
                            }
                            
                            self.timer = Timer.scheduledTimer(timeInterval: 1/24, target: self, selector: #selector(self.updataVideoFrame), userInfo: nil, repeats: true)
                            self.timer.fire()
                        }
                    }
                } else {    // 取消
                    self.isAnalysingVideo = false
                }
                
                sender.isEnabled = true
            }
        } else {
            // 主线程提醒
            DispatchQueue.main.async {
                self.showStopAlert()
            }
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
    
    
    // 更新视频帧
    @objc func updataVideoFrame() {
        
        count += 1      // 刷新次数+1
    
        if let dict = ImageConverter.getVideoFrame() {
            let isFinished = dict["finish"] as! Bool
        
            // 当前视频处理完毕
            if isFinished == true {
                self.isAnalysingVideo = false
                print("VideoStremVC: 当前视频处理完毕!")
                setFinalStateUI()
                timer.invalidate()
                return
            } else {
                
                if count == 24 {    // 已经刷新24次，更新fps计数
                    fpsLabel.stringValue = "\(fps) FPS"
                    fps = 0
                    count = 0
                }

                let isAnalysing = dict["analysing"] as! Bool
                
                if !isAnalysing {
                    self.frameModel = FrameModel.getModel(dict: dict["info"] as! NSMutableDictionary)

                    // 刷新UI
                    updateUI(frame: self.frameModel)
                   
                    fps += 1
                } else {    // 正在处理视频但没有缓存帧
                    
                }
            }
       }
    }
    
    // 视频检测中途退出提醒
    private func showStopAlert() {
        // alert提醒
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.icon = NSImage(named: "AppIcon")
        alert.addButton(withTitle: "退出")
        alert.addButton(withTitle: "继续检测")
        alert.messageText = "你想在完成检测前退出吗?"
        alert.informativeText = "停止会中断当前检测过程，导致检测结果不完整"
        alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { (modalResponse) in
           
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {    // 退出
                
                if self.isAnalysingVideo == true {
                    ImageConverter.stopAndQuit()
                    self.isAnalysingVideo = false
                }
                
            } else if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
                print("继续检测")
            }
        }
    }
    
    // 路径有误时提醒
    private func showErrorAlert() {
        // alert提醒
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.icon = NSImage(named: "AppIcon")
        alert.addButton(withTitle: "退出")
        alert.messageText = "未能成功加载视频!"
        alert.informativeText = "请检查视频路径中是否有空格或汉字, 若有则无法正常加载视频!"
        alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { (modalResponse) in
          
        if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
               
           }
       }
    }
    
    // 设置视频结束后的UI界面
    private func setFinalStateUI() {
        
        self.plateModels.removeAll()
        
        showArea.stopAnimation()
    }
    
    // 刷新UI
    private func updateUI(frame: FrameModel) {
        
        // 处理当前帧包含的模型
        procPlateModels(frame: frame)
        
        videoArea.updateUI(frame: frame)
        recordArea.updateUI(models: self.plateModels)
        
        let pCount = getPlatesCount()
        stateArea.updateUI(resolution: frame.resolutionStr, count: pCount)
        
        showArea.updateModels(models: self.plateModels)
    }
    
    // 剔除不同帧包含的重复车牌
    private func procPlateModels(frame: FrameModel) {
        
        if let models = frame.plateModels {
            // 初次添加
            if plateModels.count == 0 {
                plateModels.append(contentsOf: models)
                return
            }
            
            var tempModels = [PlateInfoModel]()
            for model in models {
                let license = model.plateLicense!
                var flag = false         // 当前车牌是否为重复车牌
    
                for oldModel in plateModels {
                    let oldLicense = oldModel.plateLicense!
                    var sameCount = 0               // 相同位置字符相同的个数
                    for i in 1..<license.count {    // 比较后六个字符
                        if license[i] == oldLicense[i] {
                            sameCount += 1
                        }
                    }
                    
                    if sameCount > 3 {     // 相同车牌
                        flag = true
                        break;
                    }
                }
                
                if flag == false {
                    tempModels.append(model)
                }
            }
            
            plateModels.append(contentsOf: tempModels)
        }
    }
    
    // 截止到当前帧识别到的所有车牌数(蓝牌, 黄牌)
    private func getPlatesCount() -> (blue: Int, yellow: Int) {
        var blueCount = 0
        var yellowCount = 0
        
        for model in plateModels {
            if model.plateColor == "蓝牌" {
                blueCount += 1
            } else {
                yellowCount += 1
            }
        }
        return (blueCount, yellowCount)
    }
}

// MARK: - RecordWinViewProtocal
extension VideoStreamViewController: RecordWinViewProtocal {
    
    func cellDidClicked(_ recordWinView: RecordWinView, plateModel: PlateInfoModel) {
        if recordDetailView == nil {
            recordDetailView = RecordDetailView(frame: NSRect(x: 8, y: 8, width: 300, height: 600))
            recordDetailView.delegate = self
        }
        
        contentView.addSubview(recordDetailView)
        recordDetailView.showCircleAnimation(model: plateModel)
    }
}

// MARK: - RecordDetailViewProtocol
extension VideoStreamViewController: RecordDetailViewProtocol {
    
    func hideAnimationFinished(_ detailView: RecordDetailView) {
        recordDetailView.removeFromSuperview()
    }
    
}

// MARK: - BottomViewProtocol
extension VideoStreamViewController: BottomViewProtocol {
    
    func buttonPressed(_ bottomView: BottomView, sender: NSButton) {
        analyseVideo(sender: sender)
    }
}

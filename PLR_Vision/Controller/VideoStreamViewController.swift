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
    @IBOutlet weak var shadowView: NSView!
    @IBOutlet weak var circleButton: NSButton!
    @IBOutlet weak var videoArea: VideoWinView!
    @IBOutlet weak var stateArea: StateWinView!
    @IBOutlet weak var recordArea: RecordWinView!
    
    @IBOutlet weak var showArea: ShowWinView!
    
    @IBOutlet weak var fpsLabel: NSTextField!
    
    
    var recordDetailView: RecordDetailView!
    
    
    var timer: Timer!
    var fps = 0
    var count = 0
    
    var frameModel: FrameModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        
    }
    
    func setupUI() {
        
        recordArea.delegate = self
        
        circleButton.wantsLayer = true
        circleButton.layer?.cornerRadius = 35
        circleButton.layer?.backgroundColor = L_Yellow
              
        shadowView.wantsLayer = true
        shadowView.layer?.cornerRadius = 45
        shadowView.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.7)

       
    }
    
    @IBAction func analyseVideo(_ sender: NSButton) {
        
        showArea.slideAnimation()
        
//        // 视频文件选择
//        let panel = NSOpenPanel()
//        panel.canChooseFiles = true
//        panel.canChooseDirectories = false
//        panel.allowsMultipleSelection = false
//        panel.canCreateDirectories = false
//        panel.allowedFileTypes = ["mp4"]
//        panel.begin { (result) in
//            if result == .OK {
//                if let url = panel.url {
//
//                    var path = url.absoluteString
//                    let range = path.startIndex...path.index(path.startIndex, offsetBy: 6)
//                    path.removeSubrange(range)
//
//
//                   // 后台处理视频
//                   DispatchQueue.global().async {
//                       ImageConverter.startAnalyseVideo(path, svmPath: SVM_MODEL_PATH, charPath: CNN_CHAR_MODEL_PATH, zhPath: CNN_ZH_MODEL_PATH, outPath: CACHE_PATH)
//                   }
//
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//                        self.timer = Timer.scheduledTimer(timeInterval: 1/24, target: self, selector: #selector(self.updataVideoFrame), userInfo: nil, repeats: true)
//                        self.timer.fire()
//                    }
//                }
//            }
//        }
        
        
    }
    
    
    // 更新视频帧
    @objc func updataVideoFrame() {
        
        count += 1      // 刷新次数+1
    
        if let dict = ImageConverter.getVideoFrame() {
            let isFinished = dict["finish"] as! Bool
        
            // 当前视频处理完毕
            if isFinished == true {
                print("当前视频处理完毕!")
                
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
    
    
    // 刷新UI
    private func updateUI(frame: FrameModel) {
        
        stateArea.updateUI(frame: frame)
        
        videoArea.updateUI(frame: frame)
        
        recordArea.updateUI()
        
    }
}

// MARK: - RecordWinViewProtocal
extension VideoStreamViewController: RecordWinViewProtocal {
    
    
    func cellDidClicked(_ recordWinView: RecordWinView, plateModel: PlateInfoModel?) {
        
        print("弹出侧滑详情页面!")
        
        showDetailViewWithCircleAnim()
    }
    
    func showDetailViewWithCircleAnim() {
        
        if recordDetailView == nil {
            // width: 10-280-10   height: 10-585-10
            recordDetailView = RecordDetailView(frame: NSRect(x: 8, y: 8, width: 300, height: 600))
            recordDetailView.delegate = self
        }
        
        contentView.addSubview(recordDetailView)
        recordDetailView.showCircleAnimation()
        
    }
}

// MARK: - RecordDetailViewProtocol
extension VideoStreamViewController: RecordDetailViewProtocol {
    
    func hideAnimationFinished(_ detailView: RecordDetailView) {
        recordDetailView.removeFromSuperview()
    }
    
}

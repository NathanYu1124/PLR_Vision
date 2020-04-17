//
//  VideoViewController.swift
//  PLR_Vision
//
//  Created by NathanYu on 2018/5/7.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class VideoViewController: NSViewController {
    @IBOutlet weak var countLabel: NSTextField!
    
    @IBOutlet weak var videoWindow: NSImageView!
    
    @IBOutlet weak var platesInfoList: NSTableView!
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    var selectButton: CircularButton!
    var videoPath: String!
    var timer: Timer!
    var finished = false
    var isPlaying = false   // 当前是否有视频播放
    
    
    var detailView: DetailView?
    
    
    var plateModels: [PlateInfoModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    func setupUI() {
        
        self.view.wantsLayer =  true
        self.view.layer?.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 1).cgColor
        
        selectButton = CircularButton()
        selectButton.button.delegate = self
        selectButton.frame = NSMakeRect(365, 5, 90, 90)
        selectButton.state = .select
        self.view.addSubview(selectButton)
        
        platesInfoList.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 0.7)
        platesInfoList.register(NSNib(nibNamed: NSNib.Name(rawValue: "PlateCell"), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PlateCellID"))
        platesInfoList.action = #selector(cellClicked)
        
        scrollView.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 0.8)
        
    }
    
    
    // 初始状态
    func resetToDefaultState() {
        // 更改播放器视图
        self.videoWindow.image = NSImage(named: NSImage.Name(rawValue: "videoPlay"))
        
        // 清空识别列表
        self.plateModels = nil
        self.platesInfoList.reloadData()
        
        // 重置识别车牌数
        self.countLabel.stringValue = "识别车牌数: 0"
        
        // 重置主按钮状态
        self.selectButton.state = .select
        
    }
    
}

// MARK: - tableView delegate
extension VideoViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let model = self.plateModels[row]
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PlateCellID"), owner: nil) as! PlateCell
        
        cell.updateUI(color: model.plateColor, license: model.plateLicense)

        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 45
    }
    
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "rowview"), owner: nil) as? CustomRowView
        if rowView == nil {
            rowView = CustomRowView()
            rowView!.identifier = NSUserInterfaceItemIdentifier(rawValue: "rowview")
        }
        return rowView
    }
    
}

// MARK: - tableView dataSource
extension VideoViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (plateModels == nil) ? 0 : plateModels!.count
    }
}

extension VideoViewController: CustomBtnProtocal {
    func buttonPressed(_ button: CustomButton) {
        switch button.currentState {
        case .scan:
            if isPlaying == false {
                
                // 清空缓存区数据
                ImageConverter.clearCacheData();
                
                // 清空程序缓存数据
                self.plateModels = nil
                self.platesInfoList.reloadData()
                self.countLabel.stringValue = "识别车牌数: 0"
                
                analyseVideo()
                
                // 标记为：有视频正在播放
                isPlaying = true
            }
        case .select:
            chooseVideoFromFiles()
        case .stop:
    
            // alert提醒
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.icon = NSImage(named: NSImage.Name(rawValue: "AppIcon"))
            alert.addButton(withTitle: "退出")
            alert.addButton(withTitle: "继续检测")
            alert.messageText = "你想在完成检测前退出吗?"
            alert.informativeText = "停止会中断当前检测过程，导致检测结果不完整"
            alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { (modalResponse) in
               
                if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                    print("退出")
                    
                    if self.isPlaying == true {
                        ImageConverter.stopAndQuit()
                        
                        self.isPlaying = false
                        
                        self.resetToDefaultState()
                    }
                    
                } else if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
                    print("继续检测")
                } else {
                    print("其他按钮")
                }
            }
    
            break
        }
    }
}

extension VideoViewController: DetailViewProtocal {
    // 语音播报车牌号
    func playPlateSound(_ detailView: DetailView, license: String, sender: NSButton) {
        
        sender.image = NSImage(named: NSImage.Name(rawValue: "audio_on"))
        // 播放时不再可交互
        sender.isEnabled = false
        
        AudioTool.playPlateSound(license: license as NSString)
        
    }
    
    // 退出车牌详情界面
    func backToMainView(_ detailView: DetailView) {
        self.detailView!.removeFromSuperview()
        self.platesInfoList.isHidden = false
        self.scrollView.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 0.8)
    }
}

extension VideoViewController {
    
    
    // 转到识别详情页面
    @objc func cellClicked() {
        let model = self.plateModels[self.platesInfoList.selectedRow]
        pushToDetailView(plateModel: model)
    }
    
    func pushToDetailView(plateModel: PlateInfoModel) {
        if let view = DetailView.creatViewFromNib() {
            print("Load detail view successfully!")
            self.detailView = view
            self.detailView!.frame = NSMakeRect(580, 105, 210, 497)
            self.detailView!.delegate = self
            self.view.addSubview(self.detailView!)
            self.platesInfoList.isHidden = true
            self.scrollView.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 1)
            self.detailView!.layoutUI(plateModel: plateModel)
        } else {
            print("Can't load view from nib!!!")
        }
    }
    
    // 视频文件选择
    func chooseVideoFromFiles() {
        // 视频文件选择
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.allowedFileTypes = ["avi"]
        panel.begin { (result) in
            if result == .OK {
                if let url = panel.url {
                    
                    var path = url.absoluteString
                    let range = path.startIndex...path.index(path.startIndex, offsetBy: 6)
                    path.removeSubrange(range)
                    
                    self.videoPath = path
                    self.selectButton.state = .scan
                }
            }
        }
    }
    
    // 视频流分析
    func analyseVideo() {
//        self.finished = false
//        
//        if let path = videoPath {
//            
//            // 后台处理视频
//            DispatchQueue.global().async {
//                ImageConverter.startAnalyseVideo(path)
//                self.finished = true
//                
//                // 当前无视频正在播放
//                self.isPlaying = false
//            }
//            
//            updataVideoFrame()
//            timer = Timer.scheduledTimer(timeInterval: 1/30, target: self, selector: #selector(updataVideoFrame), userInfo: nil, repeats: true)
//            timer?.fire()
//            
//            // 更改主按钮状态为停止
//            self.selectButton.state = .stop
//        }
    }
    
    // 更新视频帧
    @objc func updataVideoFrame() {
        
        if let dict = ImageConverter.getVideoFrame() {
            let state = dict["finish"] as! Bool
            if state == true {
                if self.finished == true {
                    timer?.invalidate()
                    self.selectButton.state = .select
                }
            } else {
                self.videoWindow.image = dict["frame"] as? NSImage
                
                let models = PlateInfoModel.getVideoModels(dict: dict)
                self.plateModels = models
                self.platesInfoList.reloadData()
                let count = self.plateModels.count
                
                self.countLabel.stringValue = "识别车牌数: \(count)"
            }
        }
    }
}

















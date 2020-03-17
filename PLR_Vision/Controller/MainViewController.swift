//
//  MainViewController.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/7.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa
import AVFoundation

class MainViewController: NSViewController {
    
    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var carImageView: NSImageView!
    @IBOutlet weak var plateLabel: NSTextField!
    @IBOutlet weak var welcomeLabel: NSTextField!
    
    @IBOutlet weak var resultView: NSView!
    @IBOutlet weak var plateImageView: NSImageView!
    @IBOutlet weak var platesNumber: NSTextField!
    @IBOutlet weak var plateLicense: NSTextField!
    @IBOutlet weak var plateColor: NSTextField!
    @IBOutlet weak var char1: NSImageView!
    @IBOutlet weak var resChar1: NSTextField!
    @IBOutlet weak var similarity1: NSTextField!
    @IBOutlet weak var char2: NSImageView!
    @IBOutlet weak var char3: NSImageView!
    @IBOutlet weak var char4: NSImageView!
    @IBOutlet weak var char5: NSImageView!
    @IBOutlet weak var char6: NSImageView!
    @IBOutlet weak var char7: NSImageView!
    @IBOutlet weak var resChar2: NSTextField!
    @IBOutlet weak var resChar3: NSTextField!
    @IBOutlet weak var resChar4: NSTextField!
    @IBOutlet weak var resChar5: NSTextField!
    @IBOutlet weak var resChar6: NSTextField!
    @IBOutlet weak var resChar7: NSTextField!
    @IBOutlet weak var similarity2: NSTextField!
    @IBOutlet weak var similarity3: NSTextField!
    @IBOutlet weak var similarity4: NSTextField!
    @IBOutlet weak var similarity5: NSTextField!
    @IBOutlet weak var similarity6: NSTextField!
    @IBOutlet weak var similarity7: NSTextField!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var preButton: NSButton!
    @IBOutlet weak var audioButton: NSButton!
    
    var mainButton: CircularButton!
    var carImgPath: String!
    var soundPlayer: AVAudioPlayer?
    var currentIndex: Int!
    var plateCounts: Int!
    var platesDict: NSMutableDictionary?
    
    // 车牌识别结果模型
    var plateInfoModels: [PlateInfoModel]?
    
    var videoPath: String?
    var timer: Timer?
    var finished = false
    var isVideoMode = false
    
    // 懒加载
    lazy var videoViewController: VideoViewController = {
        // 从storyboard加载视图控制器
        let vc = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VideoViewController")) as! VideoViewController
        return vc
    }()
    
    // MARK: - view lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置UI
        setupUI()
    }
    
    
    func setupUI() {
        
        leftView.wantsLayer = true
        leftView.layer?.backgroundColor = NSColor(red: 44 / 255, green: 43  / 255, blue: 51 / 255, alpha: 1).cgColor
        
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 1).cgColor
        
        tableView.backgroundColor = NSColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.action = #selector(cellClicked)
        
        // 注册nib
        tableView.register(NSNib(nibNamed: NSNib.Name("CustomCell"), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCellID"))
        
        mainButton = CircularButton()
        mainButton.button.delegate = self
        mainButton.frame = NSMakeRect(365, 5, 90, 90)
        mainButton.state = .select
        mainView.addSubview(mainButton)
       
        let image = NSImage(named: NSImage.Name(rawValue: "mainlogo"))
        carImageView.image = image
        
        resultView.alphaValue = 0
        
        // 选中首行
        let firstIndex = IndexSet(integer: 0)
        tableView.selectRowIndexes(firstIndex, byExtendingSelection: false)
    }
    
   @objc func mainBtnPressed() {
        switch mainButton.state {
        case .select:
            chooseImageFromFiles()
        case .scan:
            recognizeImage()
        case .stop:
            break
    
        }
    }
    
    @IBAction func analyseVideo(_ sender: NSButton) {
      
    }
    
    @objc func updataVideoFrame() {
       
    }
    
    // 播放当前显示的车牌号码
    @IBAction func audioButtonPressed(_ sender: NSButton) {
        if soundPlayer?.isPlaying == false {
            let license = self.plateLicense.stringValue as NSString
            
            // 后台播放音乐
            DispatchQueue.global().async {
                
                self.playPlateSound(license: license)
            }
        }
    }
    
    
    // 显示下一个车牌信息
    @IBAction func nextButtonPressed(_ sender: NSButton) {
        // 显示识别出的车牌个数
        let newVal = self.currentIndex + 1
        self.currentIndex = newVal
        
        updateCharsInfoView(plateInfo: plateInfoModels![newVal - 1], index: newVal, total: self.plateInfoModels!.count)
    }
    
    // 显示上一个车牌信息
    @IBAction func preButtonPressed(_ sender: NSButton) {
        
        
        let newVal = self.currentIndex - 1
        self.currentIndex = newVal
        
        // 更新页面内容
        updateCharsInfoView(plateInfo: plateInfoModels![newVal - 1], index: newVal, total: self.plateInfoModels!.count)

    }
    
    @objc func cellClicked() {
        print("cell \(tableView.selectedRow) clicked!")
        
        if tableView.selectedRow == 1 && isVideoMode == false {    // 视频识别
           
            self.mainView.addSubview(self.videoViewController.view)
             isVideoMode = true
            
        } else if tableView.selectedRow == 0 && isVideoMode == true {   // 图片识别
            
            // 当前是否有视频正在处理
            if self.videoViewController.isPlaying == true {
                
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.icon = NSImage(named: NSImage.Name(rawValue: "AppIcon"))
                alert.addButton(withTitle: "退出")
                alert.addButton(withTitle: "继续检测")
                alert.messageText = "你想在完成检测前退出吗?"
                alert.informativeText = "停止会中断当前检测过程，导致检测结果不完整"
                alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { (modalResponse) in
                    
                    if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {    // 退出
                        
                        if self.videoViewController.isPlaying == true {
                            ImageConverter.stopAndQuit()
                            
                            self.videoViewController.isPlaying = false
                            self.videoViewController.resetToDefaultState()
                            self.videoViewController.view.removeFromSuperview()
                            self.isVideoMode = false
                            
                        }
                        
                    } else if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {    // 继续检测
                        let indexSet = IndexSet(integer: 1)
                        self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
                        
                    } else {    // 其它
                        print("其他按钮")
                    }
                }
            } else {
                // 重设为初始状态
                self.videoViewController.resetToDefaultState()
                
                self.videoViewController.view.removeFromSuperview()
                self.isVideoMode = false
            }
            
            // 切换为图片识别模式初始状态
            self.carImageView.frame.origin.x = 110
            self.carImageView.frame.origin.y = 138
            self.carImageView.frame.size.width = 600
            self.carImageView.frame.size.height = 450
            
            let image = NSImage(named: NSImage.Name(rawValue: "mainlogo"))
            carImageView.image = image
            resultView.alphaValue = 0
            welcomeLabel.isHidden = false
            welcomeLabel.stringValue = "欢迎使用PLR Vision车牌识别系统"
            
            
        }
    }
}

// MARK: - NSTableView dataSource
extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 45
    }
    
}

// MARK: - NSTableView delegate
extension MainViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCellID"), owner: nil) as! CustomCellView

        if row == 0 {
            cell.textLabel.stringValue = "图片识别"
            let img = NSImage(named: NSImage.Name(rawValue: "choseScan"))
            cell.iconView.image = img
        } else if row == 1 {
            cell.textLabel.stringValue = "视频识别"
            let img = NSImage(named: NSImage.Name(rawValue: "smartScan"))
            cell.iconView.image = img
        }
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "rowview"), owner: nil) as? CustomRowView
        if rowView == nil {
            rowView = CustomRowView()
            rowView!.identifier = NSUserInterfaceItemIdentifier(rawValue: "rowview")
        }
        return rowView
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        print("clicked!.....")
    }
    

    
}

// MARK: - custom func
extension MainViewController {
    
    
    // 更新识别页面内容, index为当前模型在数组中的位置
    func updateCharsInfoView(plateInfo: PlateInfoModel, index: Int, total: Int) {
        // 显示识别结果页面
        self.resultView.alphaValue = 1
        
        // 后台播放识别出的车牌号
        DispatchQueue.global().async {
            self.playPlateSound(license: NSString(string: plateInfo.plateLicense))
        }
        
        // 车牌图像
        self.plateImageView.image = plateInfo.plateImage
        
        // 车牌号
        self.plateLicense.stringValue = plateInfo.plateLicense
        
        // 车牌颜色
        self.plateColor.stringValue = plateInfo.plateColor
        
        // 操作按钮与当前车牌索引
        if index == -1 {    // 只有一个车牌
            self.preButton.isHidden = true
            self.nextButton.isHidden = true
            self.platesNumber.stringValue = "1"
        } else {    // 多个车牌
            self.preButton.isHidden = false
            self.nextButton.isHidden = false
            
            self.preButton.isEnabled = (index == 1) ? false : true
            self.nextButton.isEnabled = (index == total) ? false : true
            self.platesNumber.stringValue = "\(index)/\(total)"
        }
        
        // 字符详情, 根据tag值获取控件
        let charInfoArray = plateInfo.charsArray!
        for i in 1...7 {    
            let baseTag = i * 10000
            
            let charImageView = self.resultView.viewWithTag(baseTag + 1) as! NSImageView
            let charValue = self.resultView.viewWithTag(baseTag + 2) as! NSTextField
            let charSim = self.resultView.viewWithTag(baseTag + 3) as! NSTextField
            
            charImageView.image = charInfoArray[i - 1].charImage
            charValue.stringValue = charInfoArray[i - 1].charValue
            charSim.stringValue = charInfoArray[i - 1].charSim
        }
    }
    
    // 识别后更改界面
    func reLayoutUI(dict: NSMutableDictionary) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 2.0
            
        }, completionHandler: {
            self.carImageView.frame.origin.x = 20
            self.carImageView.frame.origin.y = 150
            self.carImageView.frame.size.width = 570
            self.carImageView.frame.size.height = 420
            
            // 更换绘制过的图片
            if let image = NSImage(byReferencingFile: "/Users/NathanYu/Desktop/PLR_Vision/PLR_Vision/resources/drawcar.jpg") {
                self.carImageView.image = image
            } else {
                print("can't load drawed image!")
            }
            
            // 识别信息 字典转模型
            let dictModels = PlateInfoModel.getModels(dict: dict)
            self.plateInfoModels = dictModels
            
            // 先展示首个车牌信息
            let index = (dictModels.count == 1) ? -1 : 1
            self.updateCharsInfoView(plateInfo: dictModels[0], index: index, total: dictModels.count)
            
            //  记录当前展示车牌位置
            self.currentIndex = 1
            
            // 更改主按钮状态为选择
            self.mainButton.state = .select
            self.plateLabel.stringValue = ""
        })
    }
    
    // 更换图片后恢复初始界面
    func recoveryUI() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 1.0
            self.resultView.alphaValue = 0
        }) {
            self.carImageView.frame.origin.x = 110
            self.carImageView.frame.origin.y = 138
            self.carImageView.frame.size.width = 600
            self.carImageView.frame.size.height = 450
        }
    }
    
    // 选取车辆照片
    func chooseImageFromFiles() {
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
                    let image = NSImage(contentsOf: url)
                    self.carImageView.image = image
                    
                    var path = url.absoluteString
                    let range = path.startIndex...path.index(path.startIndex, offsetBy: 6)
                    path.removeSubrange(range)
                    self.carImgPath = path
                    
                    self.mainButton.state = .scan
                    
                    self.welcomeLabel.isHidden = true
                    self.plateLabel.stringValue = ""
                    
                    // 恢复初始界面
                    self.recoveryUI()
                }
            }
        }
    }
    
    // 识别选中的车辆照片
  @objc func recognizeImage() {
    
        DispatchQueue.main.async {
            self.mainButton.state = .stop
            self.plateLabel.stringValue = "识别中..."
        
            // 加载音效
            self.prepareSound()
        }
    
        // 后台执行
        DispatchQueue.global().async {
//            if let dict = ImageConverter.getPlateLicense(self.carImgPath) {
//
//                // 主线程更新UI
//                DispatchQueue.main.async {
//
//                    // 播放成功音效
//                    self.playSound()
//
//                    // 重新布局UI
//                    self.reLayoutUI(dict: dict)
//                }
//            } else {    // 未识别出车牌时返回字典为空
//
//                // 主线程更新UI
//                DispatchQueue.main.async {
//                    // 播放失败音效
//                    self.playSound()
//
//                    self.plateLabel.stringValue = "未能检测到车牌"
//                    self.mainButton.state = .select
//                }
//
//            }
        }
    }
}

// MARK: - custom protocal
extension MainViewController: CustomBtnProtocal {
    func buttonPressed(_ button: CustomButton) {
        switch button.currentState {
        case .scan:
            recognizeImage()
        case .select:
            chooseImageFromFiles()
        case .stop:
            break
        }
    }
}

// MARK: - Sound
extension MainViewController {
    // 加载音效
    func prepareSound() {
        guard let audioFileUrl = Bundle.main.url(forResource: "scanFinished", withExtension: "aiff") else { return }
    
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print("Sound player not available: \(error)")
        }
    }
    
    // 播放音效
    func playSound() {
        soundPlayer?.play()
    }
    
    // 播放车牌号码
    func playPlateSound(license: NSString) {
        
        // 更改为正在播放图标
        DispatchQueue.main.async {
            self.audioButton.image = NSImage(named: NSImage.Name(rawValue: "audio_on"))
            
            // 播放时不再可交互
            self.audioButton.refusesFirstResponder = true
        }
        
        for i in 0...6 {
            // 加载音效
            let audioName = license.substring(with: NSMakeRange(i, 1))
            guard let audioFileUrl = Bundle.main.url(forResource: audioName, withExtension: "mp3") else { return }
            
            do {
                soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
                soundPlayer?.prepareToPlay()
            } catch {
                print("Sound player not available: \(error)")
            }
            
            // 播放
            soundPlayer?.play()
            
            while(soundPlayer!.isPlaying) {
                
            }
        }
        
        /// 更改为未播放图标
        DispatchQueue.main.async {
            self.audioButton.image = NSImage(named: NSImage.Name(rawValue: "audio_off"))
            
            // 播放完毕可再交互
            self.audioButton.refusesFirstResponder = false
        }
    }
    
}



































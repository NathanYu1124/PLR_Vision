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
    @IBOutlet weak var circleButton: NSButton!
    @IBOutlet weak var shadowView: NSView!
    @IBOutlet weak var changeView: NSView!
    @IBOutlet weak var charsView: CharsView!
    @IBOutlet weak var welcomeView: WelcomeView!
    @IBOutlet weak var timeView: TimeView!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var recordsView: RecordsView!
    @IBOutlet weak var audioButton: NSButton!
    
    private var preImage: NSImage!
    private var dictModels: [PlateInfoModel]!
    private var plateIndex: Int = 0
    private var records: Int = 0
    
    private var soundPlayer: AVAudioPlayer?
    
        
    // MARK: - View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始-欢迎界面
        contentView.isHidden = true
        bottomView.wantsLayer = true
        bottomView.layer?.backgroundColor = L_Orange
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
        
        
        // Chars View
        charsView.wantsLayer = true
        charsView.layer?.cornerRadius = 20
        charsView.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.8)

        
        changeView.wantsLayer = true
        changeView.layer?.cornerRadius = 20
        changeView.layer?.backgroundColor = CGColor(red: 249 / 255, green: 60 / 255, blue: 26 / 255, alpha: 0.6)
        
        
        platesView.wantsLayer = true
        platesView.layer?.cornerRadius = 20
        platesView.layer?.backgroundColor = CGColor(red: 56 / 255, green: 65 / 255, blue: 231 / 255, alpha: 0.7)
        
        
        circleButton.wantsLayer = true
        circleButton.layer?.cornerRadius = 35
        circleButton.layer?.backgroundColor = L_Yellow
        
        shadowView.wantsLayer = true
        shadowView.layer?.cornerRadius = 45
        shadowView.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.7)
        
        timeView.wantsLayer = true
        timeView.layer?.cornerRadius = 20
        timeView.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.7)
        
        recordsView.wantsLayer = true
        recordsView.layer?.cornerRadius = 20
        recordsView.layer?.backgroundColor = CGColor(red: 51 / 255, green: 156 / 255, blue: 201 / 255, alpha: 0.7)
    }
    
    
    @IBAction func analyseImage(_ sender: NSButton) {
        
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
//                    let image = NSImage(contentsOf: url)
                    
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
                                      
                                // 切换详情界面
                                if !self.welcomeView.isHidden {
                                          
                                    self.welcomeView.isHidden = true
                                    self.contentView.isHidden = false
                                    self.bottomView.layer?.backgroundColor = CGColor.clear
                                }
                                    
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
                            }
                        }
                    }
                }
                }
            }
                       
            sender.isEnabled = true
        }
    }
    
    func showAlert() {
        // alert提醒
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.icon = NSImage(named: NSImage.Name(rawValue: "AppIcon"))
        alert.addButton(withTitle: "退出")
        alert.messageText = "未能成功读取图片!"
        alert.informativeText = "请检查图片路径中是否有空格或汉字, 若有则无法正常加载图片!"
        alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { (modalResponse) in
          
        if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
               
           }
       }
    }
    
    func updateUI(plateModel: PlateInfoModel) {
        charsView.updateUI(charsArray: plateModel.charsArray)
        platesView.updateUI(plateModels: dictModels)
        plateDetailView.updateUI(plateModel: plateModel)
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
    
    @IBAction func playSound(_ sender: NSButton) {
        
        if let player = soundPlayer {
            if player.isPlaying { return }
        }
        
        let currentLicense = dictModels[plateIndex].plateLicense! as NSString
        
        // 后台播放音乐
        DispatchQueue.global().async {
            self.playPlateSound(license: currentLicense)
        }
    }
    
}

// MARK: - 音频处理
extension ImageViewController {
    
    // 播放车牌号码
    func playPlateSound(license: NSString) {
       
        
        for i in 0...6 {
            // 加载音效
            let audioName = license.substring(with: NSMakeRange(i, 1))
            guard let audioFileUrl = Bundle.main.url(forResource: audioName, withExtension: "mp3") else { return }
            
            do {
                soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
                soundPlayer?.enableRate = true
                soundPlayer?.rate = 2.0
                soundPlayer?.prepareToPlay()
            } catch {
                print("Sound player not available: \(error)")
            }
            
            // 播放
            soundPlayer?.play()
            
            while(soundPlayer!.isPlaying) {
                
            }
        }
    }
    
}

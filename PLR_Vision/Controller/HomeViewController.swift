//
//  HomeViewController.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/2/27.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController, NSWindowDelegate {

    @IBOutlet weak var menuView: NSView!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var dotView: NSView!
    
    @IBOutlet weak var imageButton: MenuButton!
    @IBOutlet weak var videoButton: MenuButton!
    @IBOutlet weak var settingButton: MenuButton!
    @IBOutlet weak var aboutButton: NSButton!
    private var selectedButton: MenuButton!
    
    private var aboutVC: AboutViewController!
    private var settingVC: SettingViewController!
    private var imageVC: ImageViewController!
    private var videoVC: VideoStreamViewController!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.window?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 添加子视图控制器
        aboutVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ABOUT_VC") as? AboutViewController
        addChild(aboutVC)
        
        settingVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SETTING_VC") as? SettingViewController
        addChild(settingVC)
        
        imageVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "IMAGE_VC") as? ImageViewController
        addChild(imageVC)
        
        videoVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "VIDEO_VC") as? VideoStreamViewController
        addChild(videoVC)
        
        // 初始加载
        selectedButton = imageButton
        containerView.addSubview(imageVC.view)
        
        setUI()
    }
    
    func setUI() {
        // 设置背景颜色
        menuView.wantsLayer = true
        menuView.layer?.backgroundColor = L_Yellow_D
        
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = L_White
        
        dotView.wantsLayer = true
        dotView.layer?.backgroundColor = CGColor.black
        dotView.layer?.cornerRadius = dotView.frame.size.height / 2
    }
    
    
    
    // MARK: - MenuButton actions
    // 先切换状态再执行点击事件
    @IBAction func videoButtonPressed(_ sender: MenuButton) {
        
        if sender.state == .on {    // 从 off -> on : 黑 -> 白
            let vc = getSelectedVC(button: selectedButton)
            changeMenuButtonState(button: sender)
            transition(from: vc, to: videoVC, options: .crossfade, completionHandler: nil)
        }
    }
    
    @IBAction func settingButtonPressed(_ sender: MenuButton) {
        
        if sender.state == .on {     // 从 off -> on : 黑 -> 白
            
            if videoVC.isAnalysingVideo {
                showStopAlert(pressedButton: sender)
            } else {
                let vc = getSelectedVC(button: selectedButton)
                changeMenuButtonState(button: sender)
                transition(from: vc, to: settingVC, options: .crossfade, completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func imageButtonPressed(_ sender: MenuButton) {
        
        if sender.state == .on {    // 从 off -> on : 黑 -> 白
            
            if videoVC.isAnalysingVideo {
                showStopAlert(pressedButton: sender)
            } else {
                let vc = getSelectedVC(button: selectedButton)
                changeMenuButtonState(button: sender)
                transition(from: vc, to: imageVC, options: .crossfade, completionHandler: nil)
            }
        }
    }
    
    @IBAction func aboutButtonPressed(_ sender: NSButton) {
        
        if videoVC.isAnalysingVideo {
            showStopAlert(pressedButton: sender)
        } else {
            view.addSubview(aboutVC.view)
        }
    }
    
    private func changeMenuButtonState(button: MenuButton) {
    
        selectedButton.performClick(selectedButton)     // 取消已选中按钮的on状态
        selectedButton = button
    }
    
    private func getSelectedVC(button: MenuButton) -> NSViewController {
        if button == imageButton {
            return imageVC
        } else if button == settingButton {
            return settingVC
        } else {
            return videoVC
        }
    }
    
    // MARK: - func
    private func showStopAlert(pressedButton: NSButton) {
                
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
                                
                // 先停止视频分析
                if self.videoVC.isAnalysingVideo == true {
                    ImageConverter.stopAndQuit()
                    self.videoVC.isAnalysingVideo = false
                    self.videoVC.videoArea.showFinishView()
                }
                
                // 再切换视图: video -> image(setting, about)
                if pressedButton == self.aboutButton {  // 切换到关于页面
                    self.view.addSubview(self.aboutVC.view)
                } else {
                   
                    let vc = self.getSelectedVC(button: pressedButton as! MenuButton)
                    self.changeMenuButtonState(button: pressedButton as! MenuButton)
                    self.transition(from: self.videoVC, to: vc, options: .crossfade, completionHandler: nil)
                }
        
            } else if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {    // 继续检测
                
                if pressedButton != self.aboutButton {
                    self.selectedButton = pressedButton as? MenuButton
                    self.changeMenuButtonState(button: self.videoButton)
                }
            }
        }
    }
    
    // 停止视频处理
    func stopVideoAnalysing() {
        ImageConverter.stopAndQuit()
        self.videoVC.isAnalysingVideo = false
    }
    
    func showStopAlert() -> Bool {
            
        // alert提醒
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.icon = NSImage(named: "AppIcon")
        alert.addButton(withTitle: "退出")
        alert.addButton(withTitle: "继续检测")
        alert.messageText = "你想在完成检测前退出吗?"
        alert.informativeText = "停止会中断当前检测过程，导致检测结果不完整"
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {    // 退出
            stopVideoAnalysing()
            return true
        }
        
        return false
    }
    
}


// MARK: - NSWindowDelegate
extension HomeViewController {
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if videoVC.isAnalysingVideo {
            return showStopAlert()
        }
        
        return true
    }
}

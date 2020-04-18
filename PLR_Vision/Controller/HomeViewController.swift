//
//  HomeViewController.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/2/27.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 添加子视图控制器
        aboutVC = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ABOUT_VC")) as? AboutViewController
        addChildViewController(aboutVC)
        
        settingVC = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SETTING_VC")) as? SettingViewController
        addChildViewController(settingVC)
        
        imageVC = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "IMAGE_VC")) as? ImageViewController
        addChildViewController(imageVC)
        
        videoVC = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VIDEO_VC")) as? VideoStreamViewController
        addChildViewController(videoVC)
        
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
    
    
    func showStopAlert(pressedButton: NSButton) {
                
        // alert提醒
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.icon = NSImage(named: NSImage.Name(rawValue: "AppIcon"))
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
                    self.selectedButton = pressedButton as! MenuButton
                    self.changeMenuButtonState(button: self.videoButton)
                }
            }
        }
        
    }
}



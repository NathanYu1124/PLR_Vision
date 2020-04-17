//
//  FrameModel.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/13.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Foundation
import AppKit

// 视频帧 Model
class FrameModel {
    
    // 帧原始图像
    var oriFrameImage: NSImage!
    
    // 帧渲染图像
    var frameImage: NSImage!
    
    // 视频帧率
    var fps = 0
    
    // 视频分辨率
    var resolutionStr = ""
    
    // 视频总时长
    var duration = ""
    
    // 视频当前时长
    var currentLoc = ""
    
    // 视频进度
    var progress = 0.0
    
    // 当前帧识别出的车牌
    var plateModels: [PlateInfoModel]?
    
    
    // MARK: - init
    init(oriImg: NSImage, Img: NSImage, fps: Int, resStr: String, duration: Int, loc: Int, plates: [PlateInfoModel]?) {
        
        self.oriFrameImage = oriImg
        self.frameImage = Img
        self.fps = fps
        self.resolutionStr = resStr
        self.duration = getTimeString(seconds: duration / fps)
        self.currentLoc = getTimeString(seconds: loc / fps)
        self.progress = Double(loc) / Double(duration)
        
        self.plateModels = plates
    }
    
    
    // MARK: -  func
    class func getModel(dict: NSMutableDictionary) -> FrameModel {
        
        let p_fps = dict["fps"] as! Int
        let p_res = dict["resolution"] as! String
        let p_duration = dict["duration"] as! Int
        let p_location = dict["location"] as! Int
        let p_oriImg = dict["oriFrameImg"] as! NSImage
        let p_Img = dict["frameImg"] as! NSImage
        let p_Dict = dict["plates"] as! NSMutableDictionary
        let isEmpty = p_Dict["empty"] as! Bool  // 当前帧是否包含识别出的车牌信息
        
        
        if isEmpty {
            return FrameModel(oriImg: p_oriImg, Img: p_Img, fps: p_fps, resStr: p_res, duration: p_duration, loc: p_location, plates: nil)
        } else {
            let plates = PlateInfoModel.getModels(dict: p_Dict)
            return FrameModel(oriImg: p_oriImg, Img: p_Img, fps: p_fps, resStr: p_res, duration: p_duration, loc: p_location, plates: plates)
        }
    }
    
    // 将秒转化为 时:分:秒 格式的字符串
    private func getTimeString(seconds: Int) -> String {
        
        var timeStr: String!
        
        let hours = seconds / 3600
        let minutes = seconds % 3600 / 60
        let secs = seconds % 3600 % 60
        
        if hours == 0 {
            timeStr = String(format: "%02d:%02d", minutes,secs)
            
        } else {
            timeStr = String(format: "%02d:%02d:%02d", hours,minutes,secs)
        }
        
        return timeStr
    }
    
}

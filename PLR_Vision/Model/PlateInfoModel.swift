//
//  PlateInfoModel.swift
//  PLR_Vision
//
//  Created by NathanYu on 2018/5/18.
//  Copyright © 2018年 NathanYu. All rights reserved.
//

import Foundation
import AppKit

struct charInfo {
    
    var charValue: String       // 字符值
    var charSim: String         // 字符相似度
    var charImage: NSImage      // 字符图像
    
    init(value: String, similarity: String, image: NSImage) {
        self.charValue = value
        self.charSim = similarity
        self.charImage = image
    }
}

// 车牌详情Model
class PlateInfoModel {
    
    // 车牌图像
    var plateImage: NSImage!
    
    // 车牌号
    var plateLicense: String!
    
    // 车牌颜色
    var plateColor: String!
    
    // 字典: 字符,字符相似度,字符图像
    var charsArray: [charInfo]!
    
    
    // MARK: - init
    init(plateImg: NSImage, license: String, p_color: String, infoDictArray: NSMutableArray) {
        
        self.plateImage = plateImg
        self.plateLicense = license
        self.plateColor = p_color
        
        var tempArray = [charInfo]()
        
        for i in 0..<infoDictArray.count {
            let arrayOfDict = infoDictArray[i] as! NSMutableDictionary
            
            let charValue = (arrayOfDict["char"] as! NSString) as String
            let charSim = (arrayOfDict["charSim"] as! Float) * 100
            let simStr = (charSim >= 99.995) ? "100%" : String(format: "%.2f%%", charSim)
            let charImage = arrayOfDict["charImg"] as! NSImage
            
            let char_info = charInfo(value: charValue, similarity: simStr, image: charImage)
            tempArray.append(char_info)
        }
        
        charsArray = tempArray
    }
    
    // 处理图片
    class func getModels(dict: NSMutableDictionary) -> [PlateInfoModel] {
        
        let p_counts = dict["number"] as! Int
        let p_images = dict["images"] as! NSMutableArray
        let p_licenses = dict["license"] as! NSMutableArray
        let p_colors = dict["color"] as! NSMutableArray
        let p_details = dict["detail"] as! NSMutableArray
        
        var models = [PlateInfoModel]()
        for i in 0..<p_counts {
            let dict = p_details[i] as! NSMutableArray
            let img = p_images[i] as! NSImage
            let license = (p_licenses[i] as! NSString) as String
            let color = (p_colors[i] as! NSString) as String
            
            let model = PlateInfoModel(plateImg: img, license: license, p_color: color, infoDictArray: dict)
            models.append(model)
        }
        
        return models
    }
    
    
    // 处理视频帧
    class func getVideoModels(dict: NSMutableDictionary) -> [PlateInfoModel] {
        let infoArray = dict["info"] as! NSMutableArray
        
        var models = [PlateInfoModel]()
        for i in 0..<infoArray.count {
            let infoDict = infoArray[i] as! NSMutableDictionary
            let license = (infoDict["license"] as! NSString) as String
            let p_image = infoDict["image"] as! NSImage
            let p_color = (infoDict["color"] as! NSString) as String
            let p_chars = (infoDict["detail"]) as! NSMutableArray
            
            let model = PlateInfoModel(plateImg: p_image, license: license, p_color: p_color, infoDictArray: p_chars)
            models.append(model)
        }
        
        
        return models
    }
    
}




































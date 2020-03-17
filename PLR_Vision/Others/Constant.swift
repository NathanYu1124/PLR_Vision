//
//  Constant.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/2/27.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Foundation

// MARK: -
let HomeWidth : CGFloat = 1000
let HomeHeight : CGFloat = 700

let MenuViewWidth : CGFloat = 70


// MARK: -  Custom Color

// light mode
// 246 160 29 --- 250 178 95
let L_Yellow_D : CGColor = CGColor(red: 246 / 255, green: 160 / 255, blue: 29 / 255, alpha: 1.0)
let L_Yellow : CGColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 1.0)
let L_White : CGColor = CGColor(red: 249 / 255, green: 241 / 255, blue: 233 / 255, alpha: 1.0)  
let L_Gray : CGColor = CGColor(red: 174 / 255, green: 161 / 255, blue: 174 / 255, alpha: 0.2)
let L_Orange : CGColor = CGColor(red: 249 / 255, green: 60 / 255, blue: 26 / 255, alpha: 0.8)
let L_Blue : CGColor = CGColor(red: 56 / 255, green: 65 / 255, blue: 231 / 255, alpha: 1.0)


// dark mode

// MARK: - Paths
var SVM_MODEL_PATH: String!
var CNN_CHAR_MODEL_PATH: String!
var CNN_ZH_MODEL_PATH: String!
var CACHE_PATH: String!

// MARK: -  Province
let ProvinceDict = [
    "川" : "四川", "鄂" : "湖北", "赣" : "江西",
    "甘" : "甘肃", "贵" : "贵州", "桂" : "广西",
    "黑" : "黑龙江", "沪" : "上海", "冀" : "河北",
    "津" : "天津", "京" : "北京", "吉" : "吉林",
    "辽" : "辽宁", "鲁" : "山东", "蒙" : "内蒙古",
    "闽" : "福建", "宁" : "宁夏", "青" : "青海",
    "琼" : "海南", "陕" : "陕西", "苏" : "江苏",
    "晋" : "山西", "皖" : "安徽", "湘" : "湖南",
    "新" : "新疆", "豫" : "河南", "渝" : "重庆",
    "粤" : "广东", "云" : "云南", "藏" : "西藏",
    "浙" : "浙江"
]

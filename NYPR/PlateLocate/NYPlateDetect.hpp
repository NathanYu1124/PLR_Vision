//
//  NYPlateDetect.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 24/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYPlateDetect_hpp
#define NYPlateDetect_hpp

#include <stdio.h>
#include "NYPlate.hpp"
#include "NYPlateJudge.hpp"
#include "NYPlateLocate.hpp"
#include <assert.h>

class NYPlateDetect {
    
public:
  
    // 初始化svm模型地址
    void setSVMModelPath(string svmPath);
    
    // 检测给定图片上的车牌 (综合sobel与颜色识别)
    vector<NYPlate> detectPlates(Mat src);
    
    // 检测视频流中的车牌: 牺牲精度，提高处理速度
    vector<NYPlate> detectPlatesInVideo(Mat src);
    
private:
    
    string svmModelPath;   // SVM模型地址
    
    NYPlateLocate locater;
    
    // 去除重复的车牌
    vector<NYPlate> deleteRepeatPlates(vector<NYPlate> colorVec, vector<NYPlate> sobelVec);
    
    // 车牌精定位
    void reProcessPlates(Mat src, vector<NYPlate> &plates);
};


#endif /* NYPlateDetect_hpp */

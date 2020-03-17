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
    // SVM模型地址 - 软件包中
    string svmModelPath;
    // 检测给定图片上的车牌 (综合sobel与颜色识别)
    vector<NYPlate> detectPlates(Mat src);
    
private:
    
    NYPlateLocate locater;
    
    // 去除重复的车牌
    vector<NYPlate> deleteRepeatPlates(vector<NYPlate> colorVec, vector<NYPlate> sobelVec);
    
    // 车牌精定位
    void reProcessPlates(Mat src, vector<NYPlate> &plates);
    
    // 将车牌输出到指定目录中
    void outputPlates(vector<NYPlate> platesVec);
};


#endif /* NYPlateDetect_hpp */

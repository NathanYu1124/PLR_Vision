//
//  NYPlateLocate.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 22/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYPlateLocate_hpp
#define NYPlateLocate_hpp

#include <stdio.h>
#include <iostream>
#include <opencv2/opencv.hpp>
#include "Utils.hpp"
#include "NYPlate.hpp"

using namespace std;
using namespace cv;
using namespace Utils;

// 车牌定位
class NYPlateLocate {
    
public:
    // 颜色定位车牌
    vector<NYPlate> plateLocateWithColor(Mat src);
    
    // sobel定位车牌
    vector<NYPlate> plateLocateWithSobel(Mat src);
    
    // 获取指定颜色的车牌区域灰度图
    Mat convertColorToGray(Mat src, Utils::Color r);

private:
    // 对指定车牌颜色进行匹配
    vector<NYPlate> colorMatch(Mat src,Utils::Color r);
    
    // 获取车牌区域的颜色
    Utils::Color getPlateType(Mat src);

    // 查找符合车牌特征的矩形
    bool verifySize(RotatedRect mr);
    
    // 将指定区域调整为标准尺寸
    Mat resizeToNormalSize(Mat src, cv::Size rect_size, Point2f center);
    
    // 将Mat调整为标准尺寸
    Mat resizeToNormalSize(Mat src);
    
    // 将指定区域调整为标准角度
    void rotateToNormalAngle(Mat src, Mat src_closed, Mat &out, RotatedRect roi_rect);
    
};


#endif /* NYPlateLocate_hpp */

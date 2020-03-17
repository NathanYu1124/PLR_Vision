//
//  NYPlate.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 24/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYPlate_hpp
#define NYPlate_hpp

#include "Utils.hpp"
#include <stdio.h>
#include "NYCharacter.hpp"
#include <iostream>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;
using namespace Utils;

class NYPlate {
    
public:
    
    // ------------初始化------------------    
    NYPlate();
    
    // 添加车牌字符
    void addPlateChar(NYCharacter param);
    
    //-------------setter getter----------
    // 车牌Mat setter getter
    void setPlateMat(Mat src);
    Mat getPlateMat();
    
    // 车牌Color setter getter
    void setPlateColor(Utils::Color r);
    Utils::Color getPlateColor();
    
    // 车牌颜色
    void setPlateColorStr(string color);
    string getPlateColorStr();
    
    // 车牌号 setter getter
    void setPlateLicense(string license);
    string getPlateLicense();
    
    // 车牌位置 setter getter
    void setPlatePos(RotatedRect position);
    RotatedRect getPlatePos();
    
    // 车牌字符 setter getter
    void setPlateChars(vector<NYCharacter> charsVec);
    vector<NYCharacter> getPlateChars();
    
private:
    Mat    plateMat;                  // 车牌Mat
    Utils::Color  plateColor;         // 车牌颜色
    string plateColorStr;             // 车牌颜色
    string plateLicense;              // 车牌号
    RotatedRect platePos;             // 车牌位置
    vector<NYCharacter> plateChars;   // 车牌字符  
    
};

#endif /* NYPlate_hpp */

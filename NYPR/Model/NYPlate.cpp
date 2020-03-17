//
//  NYPlate.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 24/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYPlate.hpp"

// 初始化
NYPlate::NYPlate()
{
    plateMat = Mat(36, 136, CV_8UC3);
    plateColor = UNKNOWN;
    plateLicense = "unknown";
    platePos = RotatedRect();
    plateChars = vector<NYCharacter>();
}


//--------------setter - getter---------------

// 车牌Mat
void NYPlate::setPlateMat(Mat src)
{
    plateMat = src;
}

Mat NYPlate::getPlateMat()
{
    return plateMat;
}

// 车牌Color
void NYPlate::setPlateColor(Color r)
{
    plateColor = r;
}

Color NYPlate::getPlateColor()
{
    return plateColor;
}

// 车牌颜色
void NYPlate::setPlateColorStr(std::string color)
{
    plateColorStr = color;
}

string NYPlate::getPlateColorStr()
{
    return plateColorStr;
}

// 车牌号
void NYPlate::setPlateLicense(string license)
{
    plateLicense = license;
}

string NYPlate::getPlateLicense()
{
    return plateLicense;
}

// 车牌位置
void NYPlate::setPlatePos(RotatedRect position)
{
    platePos = position;
}

RotatedRect NYPlate::getPlatePos()
{
    return platePos;
}

// 车牌字符
void NYPlate::setPlateChars(vector<NYCharacter> charsVec)
{
    plateChars.clear();
    vector<NYCharacter>::iterator itr = charsVec.begin();
    while (itr != charsVec.end()) {
        plateChars.push_back((NYCharacter)*itr);
        itr++;
    }
}

vector<NYCharacter> NYPlate::getPlateChars()
{
    return plateChars;
}

// 添加车牌字符
void NYPlate::addPlateChar(NYCharacter param)
{
    plateChars.push_back(param);
}













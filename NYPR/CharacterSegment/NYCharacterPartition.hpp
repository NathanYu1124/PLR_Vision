//
//  NYCharacterPartition.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 28/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYCharacterPartition_hpp
#define NYCharacterPartition_hpp

#include <stdio.h>
#include <algorithm>
#include "NYPlateDetect.hpp"


class NYCharacterPartition {
    
public:
    
    // 划分车牌上的字符
    vector<NYCharacter> divideCharacters(NYPlate &plate);
    
private:
    
    void sortCharsRects(vector<cv::Rect> rectVec, vector<cv::Rect> &outRect);
    
    // 清除车牌上的柳钉
    bool clearLiuDing(Mat &src);
    
    // 清除车牌上下边框并记录字符上下边缘
    void clearTopAndBottomBorder(Mat &src, vector<int> &borderVec);
    
    // 清除车牌左右边框,并记录每个字符的左右侧位置
    void clearLeftAndRightBorder(Mat &src, vector<int> &borderVec);
    
    // 判断车牌字符尺寸
    bool verifyCharSizes(Mat src);
    
    // 寻找字符分割点
    void findSplitPoints(Mat src, vector<int> &charsLoc);
    
    // 将字符Mat调整为标准尺寸
    Mat resizeToNormalCharSize(Mat char_mat);
    
    
};

#endif /* NYCharacterPartition_hpp */


























//
//  NYCharacter.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 29/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYCharacter_hpp
#define NYCharacter_hpp

#include <stdio.h>
#include <iostream>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

class NYCharacter {
    
public:
    
    // 初始化
    NYCharacter();
    
    
    // 字符Mat setter getter
    void setCharacterMat(Mat param);
    Mat getCharacterMat();
    
    // 字符 setter getter
    void setCharacterStr(string param);
    string getCharacterStr();
    
    // 字符位置 setter getter
    void setCharacterPos(cv::Rect param);
    cv::Rect getCharacterPos();
    
    // 中文bool值 setter getter
    void setIsChinese(bool param);
    bool getIsChinese();
    
    // 字符相似度 setter getter
    void setLikelyScore(double param);
    double getLikelyScore();
  
private:
    // 字符Mat
    Mat characterMat;
    
    // 字符
    string characterStr;
    
    // 字符位置
    cv::Rect characterPos;
    
    // 是否为中文字符
    bool isChinese;
    
    // 字符相似度
    double likelyScore;
};

#endif /* NYCharacter_hpp */

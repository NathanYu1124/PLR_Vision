//
//  NYCharacterJudge.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 29/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYCharacterJudge_hpp
#define NYCharacterJudge_hpp

#include <iostream>
#include <map>
#include "NYCNNOCR.hpp"

class NYCharacterJudge {
   
public:
    
    NYCharacterJudge(string charPath, string zhPath) {
        cnnOCR.loadCNNModel(charPath, zhPath);
    }
    
    // 中文字符识别
    std::map<string, float> classifyZH(Mat src);
    
    // 字母+数字识别
    std::map<string, float> classifyCharAndNum(Mat src);
    
private:
    
    NYCNNOCR cnnOCR;
};

#endif /* NYCharacterJudge_hpp */
















































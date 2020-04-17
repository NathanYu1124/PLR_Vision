//
//  NYCharacterRecognition.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 07/02/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYCharacterRecognition_hpp
#define NYCharacterRecognition_hpp

#include <stdio.h>
#include "NYCharacterJudge.hpp"
#include "NYCharacterPartition.hpp"

class NYCharacterRecognition {
    
    
public:
    
    // 初始化CNN模型路径
    void setCNNModelPath(string charPath, string zhPath);
    
    // 车牌字符识别
    vector<string> recognizeChars(vector<NYPlate> &plates);
    
    // 车牌字符识别
    string recognizeChars(NYPlate plate);
    
private:
    
    string CNN_CHAR_MODEL_PATH;     // cnn字符-数字模型地址
    string CNN_ZH_MODEL_PATH;       // cnn中文模型地址
    
    NYCharacterJudge charJudge();
    
};



#endif /* NYCharacterRecognition_hpp */

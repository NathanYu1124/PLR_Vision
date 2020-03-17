//
//  NYCharacterRecognition.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 07/02/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYCharacterRecognition.hpp"


// 车牌字符识别
vector<string> NYCharacterRecognition::recognizeChars(vector<NYPlate> &plates)
{
    vector<string> licenses;
    string plate_lic;
    
    NYCharacterPartition charsDivider;
    NYCharacterJudge charsJudge = NYCharacterJudge(CNN_CHAR_MODEL_PATH, CNN_ZH_MODEL_PATH);
    
    vector<NYCharacter> allChars;
    
    // 识别所有车牌上的字符
    for (int i = 0; i < plates.size(); i++) {
        plate_lic.clear();
        
        // 分割字符
        allChars = charsDivider.divideCharacters(plates[i]);
                
        map<string, float> res;
        if (allChars.size() == 7) {
                        
            // 识别汉字
            res = charsJudge.classifyZH(allChars[0].getCharacterMat());
            allChars[0].setLikelyScore(res.begin()->second);
            allChars[0].setCharacterStr(res.begin()->first);
            
            plate_lic += res.begin()->first;
            
            // 字符识别(数字+字母)
            for (int i = 1; i < allChars.size(); i++) {
                res = charsJudge.classifyCharAndNum(allChars[i].getCharacterMat());
                
                allChars[i].setLikelyScore(res.begin()->second);
                allChars[i].setCharacterStr(res.begin()->first);
                plate_lic += res.begin()->first;
            }
            
            plates[i].setPlateLicense(plate_lic);
            plates[i].setPlateChars(allChars);
            
            licenses.push_back(plate_lic);
        }
    }
    
    return licenses;
}


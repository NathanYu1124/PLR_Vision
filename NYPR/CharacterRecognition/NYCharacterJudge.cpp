//
//  NYCharacterJudge.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 29/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYCharacterJudge.hpp"

std::map<string, float> NYCharacterJudge::classifyCharAndNum(Mat src)
{
    map<string, float> res = cnnOCR.classifyCharAndNum(src);
    return res;
}

std::map<string, float> NYCharacterJudge::classifyZH(Mat src)
{
    map<string, float> res = cnnOCR.classifyZH(src);
    return res;
}




































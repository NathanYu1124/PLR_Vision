//
//  NYCharacter.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 29/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYCharacter.hpp"

// 初始化
NYCharacter::NYCharacter()
{
    characterMat = Mat();
    characterPos = Rect();
    characterStr = "";
    isChinese = false;
    likelyScore = 0;
}

// 字符Mat setter getter
void NYCharacter:: setCharacterMat(Mat param)
{
    characterMat = param;
}

Mat NYCharacter:: getCharacterMat()
{
    return characterMat;
}

// 字符 setter getter
void NYCharacter:: setCharacterStr(string param)
{
    characterStr = param;
}

string NYCharacter:: getCharacterStr()
{
    return characterStr;
}

// 字符位置 setter getter
void NYCharacter:: setCharacterPos(Rect param)
{
    characterPos = param;
}

Rect NYCharacter:: getCharacterPos()
{
    return characterPos;
}

// 中文bool值 setter getter
void NYCharacter:: setIsChinese(bool param)
{
    isChinese = param;
}

bool NYCharacter:: getIsChinese()
{
    return isChinese;
}

// 字符相似度 setter getter
void NYCharacter:: setLikelyScore(double param)
{
    likelyScore = param;
}

double NYCharacter:: getLikelyScore()
{
    return likelyScore;
}

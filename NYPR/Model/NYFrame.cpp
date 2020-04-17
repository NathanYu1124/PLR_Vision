//
//  NYFrame.cpp
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/12.
//  Copyright © 2020 NathanYu. All rights reserved.
//

#include "NYFrame.hpp"


//--------------  初始化  -----------------
NYFrame::NYFrame(int totalFrames, int currentFrame, int fps)
{
    cFrame = currentFrame;
    tFrames = totalFrames;
    FPS = fps;
    
    lastFrame = false;  // 默认为非最后帧
    tempFrame = false;  // 非临时帧
}

// 默认初始化用于创建临时帧
NYFrame::NYFrame()
{
    tempFrame = true;
}



//--------------setter - getter---------------

// 当前帧数
void NYFrame::setCurrentFrame(int frame)
{
    this->cFrame = frame;
}

int NYFrame::getCurrentFrame()
{
    return cFrame;
}

// 视频总帧数
void NYFrame::setTotalFrames(int frames)
{
    this->tFrames = frames;
}

int NYFrame::getTotalFrames()
{
    return tFrames;
}

// 视频帧率
void NYFrame::setFPS(int fps)
{
    this->FPS = fps;
}

int NYFrame::getFPS()
{
    return FPS;
}

// 当前原始帧Mat
void NYFrame::setOriFrameMat(Mat &src)
{
    // 需要使用 copyTo 函数, 直接赋值有问题
    src.copyTo(oriFrameMat);
}

Mat NYFrame::getOriFrameMat()
{
    return oriFrameMat;
}

// 当前渲染帧Mat
void NYFrame::setCurrentFrameMat(Mat &src)
{
    // 需要使用 copyTo 函数, 直接赋值有问题
    src.copyTo(frameMat);
}

Mat NYFrame::getCurrentFrameMat()
{
    return frameMat;
}

// 当前帧识别出的车牌
void NYFrame::setPlatesVec(vector<NYPlate> plates)
{
    this->platesVec = plates;
}

vector<NYPlate> NYFrame::getPlatesVec()
{
    return platesVec;
}

// 帧宽
void NYFrame::setFrameWidth(int width)
{
    this->fWidth = width;
}

int NYFrame::getFrameWidth()
{
    return fWidth;
}

// 帧高
void NYFrame::setFrameHeight(int height)
{
    this->fHeight = height;
}

int NYFrame::getFrameHeight()
{
    return fHeight;
}

// 视频分辨率
string NYFrame::getFrameResolution()
{
    string res;
    res += to_string(fWidth);
    res += " x ";
    res += to_string(fHeight);
    
    return res;
}

// 是否是视频最后一帧
void NYFrame::setLastFrame(bool flag)
{
    lastFrame = flag;
}

bool NYFrame::getLastFrame()
{
    return lastFrame;
}

// 是否是临时帧
bool NYFrame::isTempFrame()
{
    return tempFrame;
}

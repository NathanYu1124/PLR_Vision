//
//  NYFrame.hpp
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/12.
//  Copyright © 2020 NathanYu. All rights reserved.
//

#ifndef NYFrame_hpp
#define NYFrame_hpp

#include <opencv2/opencv.hpp>
#include "NYPlate.hpp"
#include <stdio.h>

// 视频帧类
class NYFrame {
    
public:
    
//------------- 初始化 ----------------
    NYFrame();
    NYFrame(int totalFrames, int currentFrame, int fps);

    
//-------------setter getter----------
    // 当前帧Mat setter getter
    void setCurrentFrameMat(Mat &src);
    Mat getCurrentFrameMat();
    
    // 原始帧Mat setter getter
    void setOriFrameMat(Mat &src);
    Mat getOriFrameMat();
    
    // 帧识别车牌 setter getter
    void setPlatesVec(vector<NYPlate> plates);
    vector<NYPlate> getPlatesVec();
    
    // 当前帧数 setter getter
    void setCurrentFrame(int frame);
    int getCurrentFrame();
    
    // 视频总帧数 setter getter
    void setTotalFrames(int frames);
    int getTotalFrames();
    
    // 视频帧率 setter getter
    void setFPS(int fps);
    int getFPS();
    
    // 帧宽 setter getter
    void setFrameWidth(int width);
    int getFrameWidth();
    
    // 帧高 setter getter
    void setFrameHeight(int height);
    int getFrameHeight();
    
    // 视频分辨率 getter
    string getFrameResolution();
    
    // 最后帧 setter getter
    void setLastFrame(bool flag);
    bool getLastFrame();
    
    // 临时帧
    bool isTempFrame();
    
private:
    int cFrame;         // 当前帧数
    int tFrames;        // 视频总帧数
    int FPS;            // 视频帧率
    int fWidth;         // 帧宽: 分辨率-宽
    int fHeight;        // 帧高: 分辨率-高
    bool lastFrame;     // 视频中最后一帧
    bool tempFrame;     // 临时帧 - 视频还在处理但缓存队列无有效帧时填充的帧
    string resolution;  // 视频分辨率 - 格式: 1920 x 1080
    
    Mat frameMat;       // 处理帧
    Mat oriFrameMat;    // 原始帧
    vector<NYPlate> platesVec;     // 当前帧识别出的车牌
};


#endif /* NYFrame_hpp */

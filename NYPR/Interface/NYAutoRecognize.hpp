//
//  NYAutoRecognize.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 07/02/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYAutoRecognize_hpp
#define NYAutoRecognize_hpp

#include <stdio.h>
#include <opencv2/video.hpp>
#include <opencv2/videoio.hpp>
#include "NYCharacterRecognition.hpp"
#include "NYPlateDetect.hpp"
#include "Utils.hpp"
#include "CacheQueue.hpp"
#include <queue>




class NYAutoRecognize {
    
public:
    
    string OUTPUT_PATH; // 处理后的图片存储路径: 沙盒中
        
    bool isAnalysing;   // 是否正在处理视频
    
    vector<cv::Rect> preRects;  // 上一帧中处理的矩形区域
    
    // 识别图片上的车牌号
    vector<string> recognizePlateNumber(Mat src, vector<vector<map<string, float>>> &charsScore, vector<string> &colors);
    
    vector<NYPlate> recognizePlateNumber(Mat src, string svmPath, string cnnCharPath, string cnnZHPath);
    
    vector<NYPlate> recognizeVideoPlate(Mat &src);
    
    // 分析视频流
    void analyseVideo(string videoPath);
    
    // 停止视频处理
    void stopAnalysing();
    
    // 批处理所有车牌
    void handleAllCars();
    
    // 绘制车牌
    void drawLicense(Mat &img, NYPlate plate, int index);
    
    // 处理高分辨率图片
    void scaleHDImage(Mat &src);
    
    // 轮廓按面积降序排序，去除小轮廓目标
    bool descSort(vector<cv::Point> p1, vector<cv::Point> p2);
    
    // 是否为同一个区域
    bool isSameRegion(cv::Rect r1, cv::Rect r2);
    
};


#endif /* NYAutoRecognize_hpp */

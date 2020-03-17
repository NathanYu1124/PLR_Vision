//
//  NYAutoRecognize.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 07/02/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYAutoRecognize.hpp"
#include <time.h>


using namespace Utils;

#define MAXIMAGESIZE 1000

// 停止视频处理
void NYAutoRecognize::stopAnalysing()
{
    isAnalysing = false;
    
    // 清空缓存区
    CacheQueue *queue = CacheQueue::getInstance();
    queue -> clearCacheQueue();
}


// 视频流处理
void NYAutoRecognize::analyseVideo(std::string videoPath)
{
    // 正在处理视频
    isAnalysing = true;
    
    // 获取视频缓存队列
    CacheQueue *frameQueue = CacheQueue::getInstance();
    
    // 加载视频
    VideoCapture capture(videoPath);
    if (!capture.isOpened()) {
        cout << "can't open video!" << endl;
        return;
    }
    
    Ptr<BackgroundSubtractorMOG2> bgsubtrator = createBackgroundSubtractorMOG2(20, 16, false);
    
//    Multiple commands produce '/Users/nathanyu/Library/Developer/Xcode/DerivedData/PLR_Vision-acfgolvptksthybbhmtwiwpnjjgk/Build/Products/Debug/PLR_Vision.app/Contents/Resources/license.txt':
//    1) Target 'PLR_Vision' (project 'PLR_Vision') has copy command from '/Users/nathanyu/Documents/Projects/Mac/PLR_Vision-master/TinyDNN/cereal/external/rapidjson/license.txt' to '/Users/nathanyu/Library/Developer/Xcode/DerivedData/PLR_Vision-acfgolvptksthybbhmtwiwpnjjgk/Build/Products/Debug/PLR_Vision.app/Contents/Resources/license.txt'
//    2) Target 'PLR_Vision' (project 'PLR_Vision') has copy command from '/Users/nathanyu/Documents/Projects/Mac/PLR_Vision-master/TinyDNN/cereal/external/rapidxml/license.txt' to '/Users/nathanyu/Library/Developer/Xcode/DerivedData/PLR_Vision-acfgolvptksthybbhmtwiwpnjjgk/Build/Products/Debug/PLR_Vision.app/Contents/Resources/license.txt'

    int frameFlag = 0;
    
    while (isAnalysing) {
        
        
        Mat frame, srcImage, result;
        Mat mask;
        if (!capture.read(frame)) {
            break;
        }
        
        Mat src_gray;
        cvtColor(frame, src_gray, COLOR_BGR2GRAY);
        frame.copyTo(result);
        bgsubtrator->apply(frame, mask);
        
        medianBlur(mask, mask, 5);
        
        morphologyEx(mask, mask, MORPH_CLOSE, getStructuringElement(MORPH_RECT, Size(15, 15)));
        morphologyEx(mask, mask, MORPH_OPEN, getStructuringElement(MORPH_RECT, Size(5, 5)));
        dilate(mask, mask, getStructuringElement(MORPH_RECT, Size(5, 5)));
        threshold(mask, mask, 0, 255, THRESH_BINARY + THRESH_OTSU);
        
        mask.copyTo(srcImage);
        vector<vector<Point>> contours;
        findContours(srcImage, contours, RETR_EXTERNAL, CHAIN_APPROX_NONE);
        if (contours.size() < 1) {
            continue;
        }
        
        Rect rct;
        
        sort(contours.begin(), contours.end(),[](vector<Point> p1, vector<Point> p2){
            return contourArea(p1) > contourArea(p2);
        });
        
        // 当前帧筛选出的区域
        vector<Rect> currentRects;
        for (int i = 0; i < contours.size(); i++) {
            // 第i个连通分量的外接矩阵面积小于最大面积的1/6，则认为是伪目标
            if (contourArea(contours[i]) < contourArea(contours[0]) / 4) {
                break;
            }
            
            // 包含轮廓的最小矩阵
            rct = boundingRect(contours[i]);
            rectangle(result, rct, Scalar(0,255,0), 2);
        }
        
        // 添加渲染帧到缓存区
        frameQueue->addFrameToQueue(result);
        
        if (frameFlag % 2 == 0) {
            Mat below = frame(Rect(5, frame.rows * 4/5, frame.cols - 10, frame.rows * 1/5 - 5));
            vector<NYPlate> plates = recognizeVideoPlate(below);
            frameQueue->addPlatesToCache(plates);
        }
        
        frameFlag++;
    }
}

// 判断两个矩形区域的相似度
bool NYAutoRecognize::isSameRegion(cv::Rect r1, cv::Rect r2)
{
    int abs_x = abs(r1.x - r2.x);
    int abs_y = abs(r1.y - r2.y);
    int abs_w = abs(r1.width - r2.width);
    int abs_h = abs(r1.height - r2.height);
    
    int sum = abs_x + abs_y + abs_w + abs_h;
    
    if (sum <= 15) {
        return true;
    } else {
        return false;
    }
}

// 识别视频帧中的车牌
vector<NYPlate> NYAutoRecognize::recognizeVideoPlate(cv::Mat &src)
{
    NYPlateDetect detecter;
    NYCharacterRecognition charsJudge;
    
    // 缩放图片
    Mat src_cp = src.clone();
    scaleHDImage(src_cp);
    
    // 获取SVM筛选过的所有车牌
    vector<NYPlate> plates = detecter.detectPlates(src_cp);
    
    // 识别所有车牌上的字符
    charsJudge.recognizeChars(plates);
    
    // 剔除部分车牌
    vector<NYPlate>::iterator plate_itr = plates.begin();
    while (plate_itr != plates.end()) {
        NYPlate &plt = *plate_itr;
        if (plt.getPlateChars().size() != 7) {
            plate_itr = plates.erase(plate_itr);
        } else {
            plate_itr++;
        }
    }
    
//    // 绘制车牌位置
//    for (int i = 0; i < plates.size(); i++) {
//        RotatedRect rect = plates[i].getPlatePos();
//        rect.angle = 0;
//
//        if (plates[i].getPlateChars().size() == 7) {
//            rectangle(src, rect.boundingRect(), Scalar(0,0,255), 2);
//        }
//    }
    
    return plates;
}

vector<NYPlate> NYAutoRecognize::recognizePlateNumber(cv::Mat src, string svmPath, string cnnCharPath, string cnnZHPath)
{
    NYPlateDetect detecter;
    NYCharacterRecognition charsJudge;
    
    // 缩放图片
    Mat src_cp = src.clone();
    scaleHDImage(src_cp);
    
    // 初始化SVM模型地址
    detecter.svmModelPath = svmPath;
    
    // 获取SVM筛选过的所有车牌
    vector<NYPlate> plates = detecter.detectPlates(src_cp);
    
    // 初始化CNN字符模型地址
    charsJudge.CNN_CHAR_MODEL_PATH = cnnCharPath;
    charsJudge.CNN_ZH_MODEL_PATH = cnnZHPath;
    
    // 识别所有车牌上的字符
    charsJudge.recognizeChars(plates);
    
//    cout << "before erase: " << plates.size() << endl;
    
    
    // 剔除部分车牌
    vector<NYPlate>::iterator plate_itr = plates.begin();
    while (plate_itr != plates.end()) {
        NYPlate &plt = *plate_itr;
        if (plt.getPlateChars().size() != 7) {
           plate_itr = plates.erase(plate_itr);
        } else {
            plate_itr++;
        }
    }
    
//    cout << "after erase: " << plates.size() << endl;
    
    
    // 绘制车牌位置
    for (int i = 0; i < plates.size(); i++) {
        drawLicense(src_cp, plates[i], i);
    }
    
    return plates;
}

vector<string> NYAutoRecognize::recognizePlateNumber(Mat src, vector<vector<map<string, float>>> &charsScore,
                                                     vector<string> &colors)
{
    NYPlateDetect detecter;
    NYCharacterRecognition charsJudge;
    vector<string> licenses;
    
    // 缩放图片
    Mat src_cp = src.clone();
    scaleHDImage(src_cp);
    
    // 获取SVM筛选过的所有车牌
    vector<NYPlate> plates = detecter.detectPlates(src_cp);
    
    // 识别所有车牌上的字符
    licenses = charsJudge.recognizeChars(plates);
    
    // 获取每个字符识别结果及相似度
    for (int i = 0; i < plates.size(); i++) {
        vector<map<string, float>> temp;
        vector<NYCharacter> allChars = plates[i].getPlateChars();
        for (int j = 0; j < allChars.size(); j++) {
            map<string, float> a;
            a[allChars[j].getCharacterStr()] = (float)allChars[j].getLikelyScore();
            temp.push_back(a);
        }
        charsScore.push_back(temp);
    }
    
    
    for (int i = 0; i < plates.size(); i++) {
        string plateColor;
        if (plates[i].getPlateColor() == BLUE) {
            plateColor = "蓝牌";
        } else if (plates[i].getPlateColor() == YELLOW) {
            plateColor = "黄牌";
        } else {
            plateColor = "蓝牌";
        }
        
        colors.push_back(plateColor);
        // 绘制车牌区域
        drawLicense(src_cp, plates[i], i);
    }
    
    return licenses;
}

// 批处理所有图片并输出定位车牌
void NYAutoRecognize::handleAllCars() {
    
}

// 绘制车牌信息
void NYAutoRecognize::drawLicense(Mat &img, NYPlate plate, int index) {
    
    RotatedRect rect = plate.getPlatePos();
    rect.angle = 0;
    
    // 框出车牌位置
    if (plate.getPlateChars().size() == 7) {
        rectangle(img, rect.boundingRect(), Scalar(0,0,255), 2);
    }
    
    // 保存图片
    string drawPath = OUTPUT_PATH + "/drawcar.jpg";
    imwrite(drawPath, img);
    

    // 保存车牌
    Mat plr = plate.getPlateMat();
    char plrPath[300];
    sprintf(plrPath, "%s/plate%d.jpg", OUTPUT_PATH.c_str() ,index);
    imwrite(plrPath, plr);

    // 保存字符
    char charPath[300];
    sprintf(charPath, "%s/%dchar_", OUTPUT_PATH.c_str(), index);
    vector<NYCharacter> allChars = plate.getPlateChars();
    char chPath[300];
    for (int i = 0; i < allChars.size(); i++) {
        sprintf(chPath, "%s%d.jpg", charPath, i);
        imwrite(chPath, allChars[i].getCharacterMat());
    }
    
}

// 缩放高分辨率图片
void NYAutoRecognize::scaleHDImage(cv::Mat &src)
{
    if (src.rows > MAXIMAGESIZE || src.cols > MAXIMAGESIZE) {
        double widthRatio = src.cols / (double)MAXIMAGESIZE;
        double heightRatio = src.rows / (double)MAXIMAGESIZE;
        double realRatio = max(widthRatio, heightRatio);
        
        int newWidth = int(src.cols / realRatio);
        int newHeight = int(src.rows / realRatio);
        
        cv::resize(src, src, Size(newWidth, newHeight), 0, 0);
    }
}






































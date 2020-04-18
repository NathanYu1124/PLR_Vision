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
void NYAutoRecognize::analyseVideo(std::string videoPath, bool &flag)
{
    // 正在处理视频
    isAnalysing = true;
    
    // 获取视频缓存队列
    CacheQueue *frameQueue = CacheQueue::getInstance();
    
    // 加载视频
    VideoCapture capture(videoPath);
    if (!capture.isOpened()) {
        cout << "NYAutoRecognize: Can't open video!" << endl;
        flag = false;
        return;
    }
    
    Ptr<BackgroundSubtractorMOG2> bgsubtrator = createBackgroundSubtractorMOG2(20, 16, false);

    int frameFlag = 1;      // 记录视频当前处理帧数
    
  
    Mat frame, srcImage, result;
    Mat mask;
    
    // 循环读取视频帧
    while (capture.read(frame)) {
        
        // 外部取消了当前视频的继续检测
        if (isAnalysing == false) { break;}
        
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
        
        // 获取视频信息
        int frameWidth = capture.get(CAP_PROP_FRAME_WIDTH);         // 帧宽
        int frameHeight = capture.get(CAP_PROP_FRAME_HEIGHT);       // 帧高
        int frameCount = capture.get(CAP_PROP_FRAME_COUNT);         // 总帧数
        int fps = capture.get(CAP_PROP_FPS);                        // 帧率
                    
        // 保存帧信息
        NYFrame saveFrame = NYFrame(frameCount, frameFlag, fps);
        saveFrame.setFrameHeight(frameHeight);
        saveFrame.setFrameWidth(frameWidth);
        saveFrame.setOriFrameMat(frame);
        saveFrame.setCurrentFrameMat(result);
        
        // 隔帧处理检测车牌，提高处理速度
        if (frameFlag % 4 == 0) {
            Mat below = frame(Rect(5, frame.rows * 4/5, frame.cols - 10, frame.rows * 1/5 - 5));
            
            vector<NYPlate> plates = recognizeVideoPlate(below);

            saveFrame.setPlatesVec(plates);
        }
        
        frameQueue->addFrameToQueue(saveFrame);
        frameFlag++;
    }
    
    // 视频正常处理完毕
    cout << "NYPR: 当前视频处理完毕!" << endl;
    isAnalysing = false;
    
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

// 识别视频帧中的车牌: 牺牲精度，提高处理速度
vector<NYPlate> NYAutoRecognize::recognizeVideoPlate(cv::Mat &src)
{
    NYPlateDetect detecter;
    NYCharacterRecognition charsJudge;
    
    // 初始化模型地址
    detecter.setSVMModelPath(svmModelPath);
    charsJudge.setCNNModelPath(CNN_CHAR_MODEL_PATH, CNN_ZH_MODEL_PATH);
    
    // 缩放图片
    Mat src_cp = src.clone();
//    scaleFrameOfVideo(src_cp);
    
    // 获取SVM筛选过的所有车牌
    vector<NYPlate> plates = detecter.detectPlatesInVideo(src_cp);
    
    // 识别所有车牌上的字符
    charsJudge.recognizeChars(plates);
    
    // 粗处理: 剔除重复车牌
    vector<NYPlate>::iterator plate_itr = plates.begin();
    while (plate_itr != plates.end()) {
        NYPlate &plt = *plate_itr;
        if (plt.getPlateChars().size() != 7) {
            plate_itr = plates.erase(plate_itr);
        } else {
            plate_itr++;
        }
    }
    
    return plates;
}

// 识别图片中的车牌
vector<NYPlate> NYAutoRecognize::recognizePlateNumber(cv::Mat &src)
{
    NYPlateDetect detecter;
    NYCharacterRecognition charsJudge;
    
    // 缩放图片
    Mat src_cp = src.clone();
    scaleHDImage(src_cp);
    
    // 初始化SVM模型地址
    detecter.setSVMModelPath(svmModelPath);
    
    // 获取SVM筛选过的所有车牌
    vector<NYPlate> plates = detecter.detectPlates(src_cp);
    
    cout << "NYAutoRecognize: 车牌个数 -> " << plates.size() << endl;
    
    // 初始化CNN字符模型地址
    charsJudge.setCNNModelPath(CNN_CHAR_MODEL_PATH, CNN_ZH_MODEL_PATH);
   
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

// 缓存车牌与字符图像
void NYAutoRecognize::drawLicense(Mat &img, NYPlate plate, int index) {
    
    RotatedRect rect = plate.getPlatePos();
    rect.angle = 0;
    
    // 框出车牌位置
    if (plate.getPlateChars().size() == 7) {
        rectangle(img, rect.boundingRect(), Scalar(0,0,255), 2);
    }
    
    bool flag;
    
    // 保存图片
    string drawPath = OUTPUT_PATH + "/drawcar.jpg";
    flag = imwrite(drawPath, img);
    if (!flag) {
        cout << "缓存绘制的图片失败!" << endl;
    }

    // 保存车牌
    Mat plr = plate.getPlateMat();
    char plrPath[800];
    sprintf(plrPath, "%s/plate%d.jpg", OUTPUT_PATH.c_str() ,index);
    flag = imwrite(plrPath, plr);
    if (!flag) {
        cout << "缓存截取的车牌失败!" << endl;
    }
    

    // 保存字符
    char charPath[800];
    sprintf(charPath, "%s/%dchar_", OUTPUT_PATH.c_str(), index);
    vector<NYCharacter> allChars = plate.getPlateChars();
    char chPath[800];
    for (int i = 0; i < allChars.size(); i++) {
        sprintf(chPath, "%s%d.jpg", charPath, i);
        flag = imwrite(chPath, allChars[i].getCharacterMat());
        if (!flag) {
            cout << "缓存分割的字符失败!" << endl;
        }
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

// 等比缩放视频帧，提高处理速度
void NYAutoRecognize::scaleFrameOfVideo(Mat &src)
{
    double scaleRatio = 0.5;
    int newWidth = int(src.cols * scaleRatio);
    int newHeight = int(src.rows * scaleRatio);
    
    cv::resize(src, src, Size(newWidth, newHeight));
}

// 初始化模型路径
void NYAutoRecognize::setModelPath(string cachePath, string svmPath, string charPath, string zhPath)
{
    OUTPUT_PATH = cachePath;
    svmModelPath = svmPath;
    CNN_CHAR_MODEL_PATH = charPath;
    CNN_ZH_MODEL_PATH = zhPath;
}






































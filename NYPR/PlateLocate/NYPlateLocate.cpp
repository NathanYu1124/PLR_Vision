//
//  NYPlateLocate.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 22/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYPlateLocate.hpp"


#define GAUSSIAN_SIZE   5    // 高斯模糊半径

#define MORPH_WIDTH     17   // 闭运算宽度
#define MORPH_HEIGHT    3    // 闭运算高度

#define ERROR_RATE     0.4   // 车牌特征判断误差率
#define DEFAULT_ASPECT 3.75  // 车牌宽高比
#define MIN_AREA_RATE    1   // 最小车牌面积比率
#define MAX_AREA_RATE   100  // 最大车牌面积比率

#define MAX_ANGLE       30   // 车牌最大倾斜角度
#define NORMAL_WIDTH    136  // 标准化车牌宽度
#define NORMAL_HEIGHT   36   // 标准化车牌高度



//-------------sobel定位------------------

// sobel对车牌定位
vector<NYPlate> NYPlateLocate::plateLocateWithSobel(Mat src)
{
    // 高斯模糊
    Mat src_gaussian;
    GaussianBlur(src, src_gaussian, Size(5, 5), 0,0, BORDER_DEFAULT);
    
    // 灰度化
    Mat src_gray;
    cvtColor(src_gaussian, src_gray, COLOR_BGR2GRAY);
    
    // sobel运算
    Mat grad_x, abs_grad_x, src_sobel;
    Sobel(src_gray, grad_x, CV_16S, 1, 0,3,1,0,BORDER_DEFAULT);
    convertScaleAbs(grad_x, abs_grad_x);
    addWeighted(abs_grad_x, 1, 0, 0, 0, src_sobel);
    
    // 二值化
    Mat src_threshold;
    threshold(src_sobel, src_threshold, 0, 255, THRESH_OTSU + THRESH_BINARY);
    
    // 闭运算
    Mat src_closed;
    Mat element = getStructuringElement(MORPH_RECT, Size(MORPH_WIDTH,MORPH_HEIGHT));
    morphologyEx(src_threshold, src_closed, MORPH_CLOSE, element);
    
    // 提取外部轮廓
    vector<vector<Point>> contours;
    findContours(src_closed, contours, RETR_EXTERNAL, CHAIN_APPROX_NONE);
    
    // 初步选出符合车牌特征的轮廓
    vector<RotatedRect> out_rects;
    vector<vector<Point>>::iterator itr = contours.begin();
    while (itr != contours.end()) {
        RotatedRect mr = minAreaRect((Mat)*itr);
        if (!verifySize(mr)) {
            contours.erase(itr);
        } else {
            out_rects.push_back(mr);
            itr++;
        }
    }
    
    vector<NYPlate> platesVec;
    // 车牌区域标准化
    for (int i = 0; i < out_rects.size(); i++) {
        // 调整宽高
        RotatedRect roi_rect = out_rects[i];
        float rate = (float)roi_rect.size.width / (float)roi_rect.size.height;
        if (rate < 1) { swap(roi_rect.size.width, roi_rect.size.height); }

        Mat subRegion;
        getRectSubPix(src, roi_rect.size, roi_rect.center, subRegion);
        
        // 尺寸标准化
        Mat src_resized = resizeToNormalSize(subRegion);
        
        if (src_resized.empty()) {
            cout << "NYPlateLocate: 截取车牌图像失败！" << endl;
        }

        // 初始化plate
        NYPlate plate;
        plate.setPlateMat(src_resized);
        plate.setPlatePos(roi_rect);
        Color p_color = getPlateType(src_resized);
        plate.setPlateColor(p_color);
        
        if (p_color == BLUE) {
            plate.setPlateColorStr("蓝牌");
        } else if (p_color == YELLOW) {
            plate.setPlateColorStr("黄牌");
        } else {    // 暂定
            plate.setPlateColorStr("蓝牌");
        }
        
        platesVec.push_back(plate);
    }
    
    return platesVec;
}





//--------------颜色定位-------------------

// 颜色匹配对车牌定位
vector<NYPlate> NYPlateLocate::plateLocateWithColor(Mat src)
{
    // 蓝色车牌匹配
    vector<NYPlate> platesVec = colorMatch(src, BLUE);
    
    // 黄色车牌匹配
    vector<NYPlate> yellow_plates = colorMatch(src, YELLOW);
    
    // 合并
    vector<NYPlate>::iterator itr = yellow_plates.begin();
    while (itr != yellow_plates.end()) {
        platesVec.push_back((NYPlate)*itr);
        itr++;
    }
    
    return platesVec;
}

// 获取车牌区域的颜色
Color NYPlateLocate::getPlateType(Mat src)
{
    // 阀值
    const float thresh = 0.45;
    float percent;
    
    // 是否为蓝色车牌
    Mat src_gray;
    src_gray = convertColorToGray(src, BLUE);
    percent = float(countNonZero(src_gray)) / float(src_gray.rows * src_gray.cols);
    
    if (percent > thresh) { return BLUE; }
    
    // 是否为黄色车牌
    src_gray = convertColorToGray(src, YELLOW);
    percent = float(countNonZero(src_gray)) / float(src_gray.rows * src_gray.cols);
    
    if (percent > thresh) { return YELLOW; }
    
    return UNKNOWN;
}

// 获取指定颜色的车牌区域灰度图
Mat NYPlateLocate::convertColorToGray(Mat src, Color r)
{
    // BLUE的 H范围
    const int min_blue_h = 100;
    const int max_blue_h = 140;
    
    // YELLOW的 H范围
    const int min_yellow_h = 15;
    const int max_yellow_h = 40;
    
    // S与V的范围
    const int min_sv = 45;  // 原为65
    const int max_sv = 255;
    
    int min_h = 0;
    int max_h = 0;
    
    switch (r) {
        case BLUE:              // 蓝色车牌匹配
            min_h = min_blue_h;
            max_h = max_blue_h;
            break;
        case YELLOW:        // 黄色车牌匹配
            min_h = min_yellow_h;
            max_h = max_yellow_h;
            break;
        default:
            break;
    }
    
    // 将BGR转化为HSV
    Mat src_hsv;
    cvtColor(src, src_hsv, COLOR_BGR2HSV);
    
    // 拆分HSV通道
    vector<Mat> hsv_split;
    split(src_hsv, hsv_split);
    
    // 对亮度均衡光照
    equalizeHist(hsv_split[2], hsv_split[2]);
    merge(hsv_split, src_hsv);
    
    uchar *p;   // 每一行像素指针
    int channels = src_hsv.channels();
    int nRows = src_hsv.rows;
    int nCols = src_hsv.cols * channels;
    
    // 连续存储的图像，按一行处理
    if (src_hsv.isContinuous()) {
        nCols *= nRows;
        nRows = 1;
    }
    
    // 检测图像中每一个像素
    for (int i = 0; i < nRows; i++) {
        p = src_hsv.ptr<uchar>(i);
        for (int j = 0; j < nCols; j += 3) {
            int H = p[j];
            int S = p[j+1];
            int V = p[j+2];
            
            // 匹配为蓝色或黄色
            if ((H >= min_h && H <= max_h) && (S >= min_sv && S <= max_sv) && (V >= min_sv && V <= max_sv)) {
                p[j] = 0; p[j+1] = 0; p[j+2] = 255; // 白色
            } else {
                p[j] = 0; p[j+1] = 0; p[j+2] = 0; // 黑色
            }
        }
    }
    
    // 获取灰度图
    vector<Mat> split_done;
    split(src_hsv, split_done);
    Mat src_gray = split_done[2];
    
    return src_gray;
}

// 对指定车牌颜色进行匹配  ( H 色调， S 饱和度, V 亮度 )
vector<NYPlate> NYPlateLocate::colorMatch(Mat src, Color r)
{
    
    // BLUE的 H范围
    const int min_blue_h = 100;
    const int max_blue_h = 140;
    
    // YELLOW的 H范围
    const int min_yellow_h = 15;
    const int max_yellow_h = 40;
    
    // S与V的范围
    const int min_sv = 45;   // 原为65
    const int max_sv = 255;
    
    int min_h = 0;
    int max_h = 0;
    
    switch (r) {
        case BLUE:              // 蓝色车牌匹配
            min_h = min_blue_h;
            max_h = max_blue_h;
            break;
            case YELLOW:        // 黄色车牌匹配
            min_h = min_yellow_h;
            max_h = max_yellow_h;
            break;
        default:
            break;
    }
    
    // 将BGR转化为HSV
    Mat src_hsv;
    cvtColor(src, src_hsv, COLOR_BGR2HSV);
    
    // 拆分HSV通道
    vector<Mat> hsv_split;
    split(src_hsv, hsv_split);
    
    // 对亮度均衡光照
    equalizeHist(hsv_split[2], hsv_split[2]);
    merge(hsv_split, src_hsv);
    
    uchar *p;   // 每一行像素指针
    int channels = src_hsv.channels();
    int nRows = src_hsv.rows;
    int nCols = src_hsv.cols * channels;
    
    // 连续存储的图像，按一行处理
    if (src_hsv.isContinuous()) {
        nCols *= nRows;
        nRows = 1;
    }
    
    // 检测图像中每一个像素
    for (int i = 0; i < nRows; i++) {
        p = src_hsv.ptr<uchar>(i);
        for (int j = 0; j < nCols; j += 3) {
            int H = p[j];
            int S = p[j+1];
            int V = p[j+2];
            
            // 匹配为蓝色或黄色
            if ((H >= min_h && H <= max_h) && (S >= min_sv && S <= max_sv) && (V >= min_sv && V <= max_sv)) {
                p[j] = 0; p[j+1] = 0; p[j+2] = 255; // 白色
            } else {
                p[j] = 0; p[j+1] = 0; p[j+2] = 0; // 黑色
            }
        }
    }
    
    //  高斯模糊
    GaussianBlur(src_hsv, src_hsv, Size(5, 5), 0,0, BORDER_DEFAULT);

    // 获取灰度图
    vector<Mat> split_done;
    split(src_hsv, split_done);
    Mat src_gray = split_done[2];
    
    // 二值化
    Mat src_threshold;
    threshold(src_gray, src_threshold, 0, 255, THRESH_BINARY + THRESH_OTSU);
    
    // 闭运算
    Mat src_closed;
    Mat element = getStructuringElement(MORPH_RECT, Size(MORPH_WIDTH, MORPH_HEIGHT));
    morphologyEx(src_threshold, src_closed, MORPH_CLOSE, element);
    
    // 获取轮廓
    vector<vector<Point>> contours;
    findContours(src_closed, contours, RETR_EXTERNAL, CHAIN_APPROX_NONE);
    
    // 获取轮廓最小包围矩形
    vector<RotatedRect> out_rects;
    vector<vector<Point>>::iterator itr = contours.begin();
    while (itr != contours.end()) {
        RotatedRect mr = minAreaRect((Mat)*itr);
        // 车牌区域初判断
        if (!verifySize(mr)) {
            contours.erase(itr);
        } else {
            out_rects.push_back(mr);
            itr++;
        }
    }
    
    vector<NYPlate> platesVec;

    // 车牌区域细处理
    for (int i = 0; i < out_rects.size(); i++) {

        // 调整宽高
        RotatedRect roi_rect = out_rects[i];
        float rate = (float)roi_rect.size.width / (float)roi_rect.size.height;
        if (rate < 1) { swap(roi_rect.size.width, roi_rect.size.height); }

        // 角度调整
        Mat subRegion;
        rotateToNormalAngle(src, src_closed, subRegion, roi_rect);

        // 尺寸标准化
        Mat src_resized = resizeToNormalSize(subRegion);

        // 初始化plate
        NYPlate plate;
        plate.setPlateMat(src_resized);
        plate.setPlatePos(roi_rect);
        plate.setPlateColor(r);
        
        if (r == BLUE) {
            plate.setPlateColorStr("蓝牌");
        } else if (r == YELLOW) {
            plate.setPlateColorStr("黄牌");
        } else {
            plate.setPlateColorStr("蓝牌");
        }

        platesVec.push_back(plate);
    }
    
    return platesVec;
}

// -----------------------------------------------

// 查找符合车牌特征的矩形  宽高比， 面积
bool NYPlateLocate::verifySize(RotatedRect mr)
{
    float error_rate = ERROR_RATE;    // 误差率
    float aspect  =  DEFAULT_ASPECT;  // 车牌宽高比
    
    int minArea = 34 * 10 * MIN_AREA_RATE; // 符合车牌特征的最小面积
    int maxArea = 34 * 10 * MAX_AREA_RATE; // 符合车牌特征的最大面积
    
    float rmin = aspect - aspect * error_rate;  // 符合车牌特征的最小宽高比
    float rmax = aspect + aspect * error_rate;  // 符合车牌特征的最大宽高比
    
    float area = mr.size.height * mr.size.width;
    float r = (float)mr.size.width / (float)mr.size.height;
    if (r < 1) { r = (float)mr.size.height / (float)mr.size.width; }
    
    if ((area < minArea || area > maxArea) || (r < rmin || r > rmax)) {
        return false;
    } else {
        return true;
    }
}

// 将指定区域调整为标准尺寸
Mat NYPlateLocate::resizeToNormalSize(Mat src, Size rect_size, Point2f center)
{
    // 从原图像中截取指定区域的ROI
    Mat img_crop;
    getRectSubPix(src, rect_size, center, img_crop);
    
    // 尺寸标准化
    Mat img_resized;
    img_resized.create(NORMAL_HEIGHT, NORMAL_WIDTH, CV_8UC3);
    resize(img_crop, img_resized, img_resized.size(),0,0,INTER_CUBIC);
    
    return img_resized;
}

// 将Mat调整为标准尺寸
Mat NYPlateLocate::resizeToNormalSize(Mat src)
{
    Mat img_resized;
    img_resized.create(NORMAL_HEIGHT, NORMAL_WIDTH, CV_8UC3);
    resize(src, img_resized, img_resized.size(),0,0,INTER_CUBIC);
    
    return img_resized;
}

// 将指定区域调整为标准角度
void NYPlateLocate::rotateToNormalAngle(Mat src, Mat src_closed, Mat &out, RotatedRect roi_rect)
{
    // 扩大指定区域
    roi_rect.size.width += 20;
    roi_rect.size.height += 20;
    
    // 获取扩大的指定区域
    Mat subRegion;
    getRectSubPix(src_closed, roi_rect.size, roi_rect.center, subRegion);
    
    // Canny边缘检测
    Canny(subRegion, subRegion, 50, 200, 3);
    
    // hough变换找直线
    vector<Vec4i> lines;
    HoughLinesP(subRegion, lines, 1, CV_PI/180, 50,50,10);
    cvtColor(subRegion, subRegion, COLOR_GRAY2BGR);
    
    float changedAngle = 0;
    int line_count = 0;
    for (size_t i = 0; i < lines.size(); i++) {
        
        Vec4i line = lines[i];
        Point p1 = Point(line[0], line[1]);
        Point p2 = Point(line[2], line[3]);
        cv::line(subRegion, p1, p2, Scalar(0,255,0),1,LINE_AA);
        
        float angle = atan2(p1.y-p2.y, p1.x-p2.x) * 180 / CV_PI;
        if (angle > 170 || angle < -170) {
            
            if ((angle < 0 && changedAngle > 0) || (angle > 0 && changedAngle < 0)) {
                angle = - angle;
            }
            
            changedAngle += angle;
            line_count++;
        }
    }
    // 直线的平均倾斜角度
    changedAngle = changedAngle / line_count;
    
    float angle = 0;
    if (changedAngle < 0) { // 调整到-180
        angle = -(-180 - changedAngle);
    } else if (changedAngle == 0) {
        angle = 0;
    }
    else {    // 调整到180
        if (changedAngle > 170) {
            angle = -(180 - changedAngle);
        }
    }
    
    roi_rect.size.width -= 20;
    roi_rect.size.height -= 20;
    
    Mat roi_mat;
    getRectSubPix(src, roi_rect.size, roi_rect.center, roi_mat);
    
    Mat roi_rotated;
    Point2f center(roi_rect.size.width / 2, roi_rect.size.height / 2);  // 旋转中心
    Mat matrix = getRotationMatrix2D(center, angle, 1); // 旋转矩阵
    warpAffine(roi_mat, roi_rotated, matrix, Size(roi_rect.size.width, roi_rect.size.height), INTER_CUBIC);  // 仿射变换旋转Mat
    
    out = roi_rotated;
}










//
//  NYPlateDetect.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 24/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYPlateDetect.hpp"

// 检测车牌
vector<NYPlate> NYPlateDetect::detectPlates(Mat src)
{
    vector<NYPlate> platesVec;
    vector<NYPlate> sobel_plates;
    vector<NYPlate> color_plates;
    
    NYPlateLocate locater;
    NYPlateJudge judge;
    
    judge.SVM_MODEL_PATH = svmModelPath;
    
    // 颜色定位
    color_plates = locater.plateLocateWithColor(src);
    color_plates = judge.judgePlates(color_plates);
    platesVec.insert(platesVec.end(), color_plates.begin(), color_plates.end());
//    cout << "color plates size :  " << color_plates.size() << endl;
    
    // sobel定位
    sobel_plates = locater.plateLocateWithSobel(src);
    sobel_plates = judge.judgePlates(sobel_plates);
    reProcessPlates(src, sobel_plates);
    
//    cout << "sobel plates size : " << sobel_plates.size() << endl;
    platesVec.insert(platesVec.end(), sobel_plates.begin(),sobel_plates.end());
    
    // 去除重复的车牌，去除sobel与color的交集
    platesVec = deleteRepeatPlates(color_plates, sobel_plates);
//    cout << "total plates size : " << platesVec.size() << endl;
    
    // 设置车牌颜色
    for (int i = 0; i < platesVec.size(); i++) {
        
    }
    
    return platesVec;
}

// 去除重复的车牌 (根据车牌区域中心位置去除)
vector<NYPlate> NYPlateDetect::deleteRepeatPlates(vector<NYPlate> colorVec, vector<NYPlate> sobelVec)
{
    vector<NYPlate> resultVec;
    
    if ((colorVec.size() == 0) && (sobelVec.size() != 0)) {
        return sobelVec;
    } else if ((colorVec.size() != 0) && (sobelVec.size() == 0)){
        return colorVec;
    } else if ((colorVec.size() == 0) && (sobelVec.size() == 0)){
        return resultVec;
    } else {
        
        vector<NYPlate>::iterator color_itr = colorVec.begin();
        vector<NYPlate>::iterator sobel_itr = sobelVec.begin();
        
        while (color_itr != colorVec.end()) {
            NYPlate color_plate = NYPlate(*color_itr);
            RotatedRect color_rect = color_plate.getPlatePos();
                        
            // 每次都重新指向头指针
            sobel_itr = sobelVec.begin();
            while (sobel_itr != sobelVec.end()) {
                NYPlate sobel_plate = NYPlate(*sobel_itr);
                RotatedRect sobel_rect = sobel_plate.getPlatePos();
                
                float offset_x = sobel_rect.center.x - color_rect.center.x;
                float offset_y = sobel_rect.center.y - sobel_rect.center.y;
                
                if (abs(offset_x) < 20 && abs(offset_y) < 20) {
                    sobelVec.erase(sobel_itr);
                } else{
                    sobel_itr++;
                }
            }
            
            color_itr++;
        }
        
        resultVec.insert(resultVec.end(), colorVec.begin(),colorVec.end());
        resultVec.insert(resultVec.end(), sobelVec.begin(),sobelVec.end());
        
        return resultVec;
    }
}

// 将车牌输出到指定目录
void NYPlateDetect::outputPlates(vector<NYPlate> platesVec)
{
    
}

// 车牌区域精定位
void NYPlateDetect::reProcessPlates(Mat src, vector<NYPlate> &plates)
{
    for (int i = 0; i < plates.size(); i++) {

        RotatedRect roi_rect = plates[i].getPlatePos();
        // 先扩大ROI区域，1,避免ROI区域只截取到部分车牌  2,为下面的膨胀操作提供足够的空间
        
//        roi_rect.size.width += 20;
//        roi_rect.size.height += 20;

        // 纠正用RotatedRect截取ROI，宽/高<1 错误截取的问题
        if (roi_rect.angle < (-70) && roi_rect.size.width < roi_rect.size.height) {
            swap(roi_rect.size.width, roi_rect.size.height);
        }

        Mat roi_mat;
        getRectSubPix(src, roi_rect.size, roi_rect.center, roi_mat);
        

        // 转换到HSV空间
        Color plateColor = plates[i].getPlateColor();
        Mat roi_hsv;
        if (plateColor == BLUE) {   // 蓝牌
            roi_hsv = locater.convertColorToGray(roi_mat, BLUE);
        } else if (plateColor == YELLOW) {   // 黄牌
            roi_hsv = locater.convertColorToGray(roi_mat, YELLOW);
        } else {    // 未知暂定为蓝牌
            roi_hsv = locater.convertColorToGray(roi_mat, BLUE);
        }

        // 去除噪声
        GaussianBlur(roi_hsv, roi_hsv, Size(3, 3), 0,0, BORDER_DEFAULT);
        Mat element = getStructuringElement(MORPH_RECT, Size(13,7));
        dilate(roi_hsv, roi_hsv, element);

        // Canny边缘检测
        Canny(roi_hsv, roi_hsv, 50, 200, 3);

        // hough变换找直线
        vector<Vec4i> lines;
        HoughLinesP(roi_hsv, lines, 1, CV_PI/180, 50,50,10);
        cvtColor(roi_hsv, roi_hsv, COLOR_GRAY2BGR);

        float changedAngle = 0;
        int line_count = 0;
        for (size_t i = 0; i < lines.size(); i++) {

            Vec4i line = lines[i];
            Point p1 = Point(line[0], line[1]);
            Point p2 = Point(line[2], line[3]);
            cv::line(roi_hsv, p1, p2, Scalar(0,255,0), 1, LINE_AA);

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

        Mat roi_rotated;
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

        Point2f center(roi_rect.size.width / 2, roi_rect.size.height / 2);  // 旋转中心
        Mat matrix = getRotationMatrix2D(center, angle, 1); // 旋转矩阵
        Mat src_rotated;
        warpAffine(roi_mat, roi_rotated, matrix, Size(roi_rect.size.width, roi_rect.size.height), INTER_CUBIC);  // 仿射变换旋转Mat

        // 精定位，只截取车牌区域
        Mat temp = roi_rotated.clone();
        Mat region;
        if (plateColor == BLUE) {   // 蓝色车牌
            region = locater.convertColorToGray(temp, BLUE);
        } else if (plateColor == YELLOW) {  // 黄色车牌
            region = locater.convertColorToGray(temp, YELLOW);
        } else {    // 车牌颜色未知，暂按蓝色处理
            region = locater.convertColorToGray(temp, BLUE);
        }

        Mat src_closed;
        Mat ele = getStructuringElement(MORPH_RECT, Size(17, 3));
        morphologyEx(region, src_closed, MORPH_CLOSE, ele);

        vector<vector<Point>> contours;
        findContours(src_closed, contours, RETR_EXTERNAL, CHAIN_APPROX_NONE);

        vector<RotatedRect> out_rects;
        vector<vector<Point>>::iterator itr = contours.begin();
        float maxArea = 0;
        RotatedRect maxRect;
        while (itr != contours.end()) {
            RotatedRect mr = minAreaRect((Mat)*itr);
            float area = mr.size.width * mr.size.height;
            if (area > maxArea) {
                maxArea = area;
                maxRect = mr;
            }
            itr++;
        }

        // 纠正用RotatedRect截取ROI，宽/高<1 错误截取的问题
        if (maxRect.angle < (-70) && maxRect.size.width < maxRect.size.height) {
            swap(maxRect.size.width, maxRect .size.height);
        }
        Mat subRegion;
        
        getRectSubPix(roi_rotated, maxRect.size, maxRect.center, subRegion);

        if (maxArea > 0 && maxArea < 4800) {
            resize(subRegion, subRegion, Size(136, 36));

            // 保存旋转后的plate
            plates[i].setPlateMat(subRegion);
        }
        
        // 保存旋转后的plate
        plates[i].setPlateMat(subRegion);
    }
}
































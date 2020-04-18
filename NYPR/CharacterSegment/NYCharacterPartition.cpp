//
//  NYCharacterPartition.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 28/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYCharacterPartition.hpp"


#define CHAR_NORMAL_WIDTH   20    // 标准字符宽度
#define CHAR_NORMAL_HEIGHT  20   // 标准字符高度

#define ANN_OUTPUT_PATH "/Users/NathanYu/Desktop/ANN/"

extern int idx = 0;

// 划分车牌上的字符
bool NYCharacterPartition::divideCharacters(NYPlate &plate, vector<NYCharacter> &charsVec)
{
    // 灰度化 颜色判断 二值化 取轮廓 找外接矩形 截取图块
    Mat src = plate.getPlateMat();
    
    // 无法读取车牌图像
    if (src.empty()) {
        cout << "NYCharacterPartition: 无法读取车牌Mat!" << endl;
        return false;
    }
    
    // 灰度化
    Mat src_gray;
    cvtColor(src, src_gray, COLOR_BGR2GRAY);
    
    // 二值化
    Mat src_threshold;
    Color p_color = plate.getPlateColor();
    
    if (p_color == YELLOW) {  // 黄色车牌二值化参数 (THRESH_BINARY_INV)
        threshold(src_gray, src_threshold, 0, 255, THRESH_BINARY_INV + THRESH_OTSU);
    } else if(p_color == BLUE) {   // 蓝色车牌二值化参数 (THRESH_BINARY)
        threshold(src_gray, src_threshold, 0, 255, THRESH_BINARY + THRESH_OTSU);
    } else {    // 其他颜色车牌 (暂默认为蓝色)
        threshold(src_gray, src_threshold, 0, 255, THRESH_BINARY + THRESH_OTSU);
    }
    
    // 去除柳钉
    clearLiuDing(src_threshold);
    
     // 去除上下边框, 获取字符上下边缘
    vector<int> topBottom;
    clearTopAndBottomBorder(src_threshold, topBottom);
    
    // 去除左右边框, 获取每个字符左右侧位置
    vector<int> leftRight;
    clearLeftAndRightBorder(src_threshold, leftRight);
    
    // 查找波峰与波谷
//    vector<int> charsLoc;
//    findSplitPoints(src_threshold, charsLoc);

    // 截取字符
    for (int i = 0; i < leftRight.size(); i += 2) {
        int x = (leftRight[i] > 0) ? leftRight[i] : 0;
        int y = (topBottom[0] > 0) ? topBottom[0] : 0;
        
        if (i == 0 && x > src.cols) {
            x = 1;
        } else if (i > 0 && x > src.cols) {
            x = leftRight[i-1] + 1;
        }

        int width = leftRight[i+1];
        if (width < 0) {
            width = 15; // 经验值
        }
        int height = topBottom[1] - topBottom[0];

        if (x + width > src_threshold.cols) {
            width = src_threshold.cols - x;
        }

        if (y + height > src_threshold.rows) {
            height = src_threshold.rows - y;
        }

        Rect re = Rect(x,y,width,height);
        Mat char_mat;
        char_mat = src_threshold(re);
        char_mat = resizeToNormalCharSize(char_mat);
        threshold(char_mat, char_mat, 0, 255, THRESH_OTSU+THRESH_BINARY);

        // 修改字符信息
        NYCharacter plate_char = NYCharacter();
        plate_char.setCharacterMat(char_mat);
        bool isChinese = (i == 0);
        plate_char.setIsChinese(isChinese);
        plate.addPlateChar(plate_char);
        
        charsVec.push_back(plate_char);
    }

    return true;
}

// 寻找字符分割点
void NYCharacterPartition::findSplitPoints(cv::Mat src, vector<int> &charsLoc)
{
    int r = src.rows;
    int c = src.cols;
    
    vector<int> locsVec;   // 记录每个字符的位置, 第一个数为字符左侧位置，第二个为字符宽度
    vector<int> colCounts;
    for (int i = 0; i < c; i++) {
        int whiteCount = 0;
        
        for (int j = 0; j < r; j++) {
            if (src.at<char>(j, i) == (char)255) {      // (j, i)
                whiteCount++;
            }
        }
        colCounts.push_back(whiteCount);
    }
    
    vector<int> diff_v(colCounts.size() - 1, 0);
    
    for (int i = 0; i != diff_v.size(); i++) {
        if (colCounts[i+1] - colCounts[i] > 0) {
            diff_v[i] = 1;
        } else if (colCounts[i+1] - colCounts[i] < 0) {
            diff_v[i] = -1;
        } else {
            diff_v[i] = 0;
        }
    }
    
    for (int i = (int)diff_v.size() - 1; i >= 0; i--) {
        if (diff_v[i] == 0 && i == diff_v.size() - 1) {
            diff_v[i] = 1;
        } else if (diff_v[i] == 0) {
            if (diff_v[i+1] >= 0) {
                diff_v[i] = 1;
            } else {
                diff_v[i] = -1;
            }
        }
    }
    
    for (int i = 0; i != diff_v.size() - 1; i++) {
        if (diff_v[i + 1] - diff_v[i] == 2) {   // 波谷
            
            // 波谷所在列白色像素特别少
            if (colCounts[i+1] < 8) {
                charsLoc.push_back(i+1);
            }
        }
    }
    
    
    // 绘制直方图
    Mat drawImg = Mat::zeros(src.rows, src.cols, CV_8UC3);
    for (int i = 0; i < src.cols; i++) {
        float value = (float)colCounts[i];
        line(drawImg, Point(i, src.rows), Point(i, src.rows-value), Scalar(0, 0, 255));
    }
    
    // 绘制波谷分界线
    for (int i = 0; i < charsLoc.size(); i++) {
        line(drawImg, Point(charsLoc[i], src.rows), Point(charsLoc[i], 0), Scalar(0, 255, 0));
    }
    
}

// 去除车牌水平方向的柳钉
bool NYCharacterPartition::clearLiuDing(Mat &src)
{
    // 每行白色像素个数（柳钉和字符）
    const int whiteThreshCount = 25;
    // 列向量
    Mat jump = Mat::zeros(1, src.rows, CV_32F);
    
    // 柳钉位置：顶端和底部
    for (int i = 0; i < src.rows * 0.3; i++) {
        int isLiuDingLine = 0;
        int whiteCount = 0;
        
        for (int j = 0; j < src.cols; j++) {    // 记录每行白色像素数
            if (src.at<uchar>(i,j) == 255) {
                whiteCount++;
            }
        }
        
        if (whiteCount < whiteThreshCount) {
            isLiuDingLine = 1;
            jump.at<float>(i) = (float)isLiuDingLine;
        }
    }
    
    for (int i = src.rows - 1; i > src.rows * 0.7; i--) {
        int isLiuDingLine = 0;
        int whiteCount = 0;
        
        for (int j = 0; j < src.cols; j++) {    // 记录每行白色像素数
            if (src.at<uchar>(i,j) == 255) {
                whiteCount++;
            }
        }
        
        if (whiteCount < whiteThreshCount) {
            isLiuDingLine = 1;
            jump.at<float>(i) = (float)isLiuDingLine;
        }
    }
    
    // 将白色像素低于阀值的行全变0
    for (int i = 0; i < src.rows; i++) {
        if (jump.at<float>(i) == 1) {
            for (int j = 0; j < src.cols; j++) {
                src.at<char>(i,j) = 0;
            }
        }
    }
    return true;
}

// 利用水平投影去除车牌上下边框, 需要记录上下字符边缘位置并用于字符分割
void NYCharacterPartition::clearTopAndBottomBorder(cv::Mat &src, vector<int> &borderVec)
{
    int r = src.rows;
    int c = src.cols;
    
    if (r == 0 || c == 0) {
        return;
    }
    
    vector<int> rowCounts;  // 记录每行白色像素数
    
    for (int i = 0; i < r; i++) {   // 遍历图片每一行寻找上下边框
        int whiteCount = 0;
        
        for (int j = 0; j < c; j++) {   // 统计每行白色像素个数
            if (src.at<char>(i, j) == (char)255) {
                whiteCount++;
            }
        }
        // 记录每行白色像素个数
        rowCounts.push_back(whiteCount);
    }
    
    // 处理上下边框
    int top = 0, bottom = r - 1;
    int i = 1;
    for (; i < r / 2; i++) {
        if (rowCounts[i-1] == 0 && rowCounts[i] != 0 ) {
            int j = i + 1;
            for (; j < i+6; j++) {
                if (rowCounts[j] == 0) {
                    break;
                }
            }
            
            if (j != i + 6) {   // 不是字符上边缘
                i = j - 1;
            } else {   // 字符上边缘
                top = i;
                break;
            }
        }
    }
    
    // 找下字符边缘,前一个为0,当前不为0，后面连续5个非0
    i = r - 2;
    for (; i > r / 2; i--) {        
        if (rowCounts[i+1] == 0 && rowCounts[i] != 0)  {
            int j = i - 1;
            for (; j > i - 6; j--) {
                if (rowCounts[j] == 0) {
                    break;
                }
            }
            
            if (j != i - 6) { // 不是字符下边缘
                i = j + 1;
            } else {    // 找到字符下边缘
                bottom = i;
                break;
            }
        }
    }
    
    if (top == 0) {
        while (top != src.rows) {
            if (rowCounts[top] >= src.cols * 0.9) {
                top++;
            } else {
                break;
            }
        }
    }
    
    
    if (bottom == r - 1) {  // 判断是否有边框
        while (bottom) {
            if (rowCounts[bottom] >= src.cols * 0.9) {
                bottom--;
            } else {
                break;
            }
        }
    }
    
    // 记录字符上下边缘
    borderVec.push_back(top - 1);
    borderVec.push_back(bottom + 1);
    
    // 去除字符上边缘以上的干扰因素
    for (int i = 0; i < top; i++) {
        for (int j = 0; j < src.cols; j++) {
            src.at<char>(i,j) = 0;
        }
    }
    
    // 去除字符下边缘以下的干扰因素
    for (int i = r - 1; i > bottom; i--) {
        for (int j = 0; j < src.cols; j++) {
            src.at<char>(i, j) = 0;
        }
    }
}


// 清除车牌左右边框, 需要记录每个字符位置并用于字符分割
void NYCharacterPartition::clearLeftAndRightBorder(cv::Mat &src, vector<int> &borderVec)
{
    int r = src.rows;
    int c = src.cols;
    
    vector<int> charsLoc;   // 记录每个字符的位置, 第一个数为字符左侧位置，第二个数为字符右侧位置，依此类推
    vector<int> colCounts;  // 记录每列白色像素数
    for (int i = 0; i < c; i++) {
        int whiteCount = 0;
        
        for (int j = 0; j < r; j++) {
            if (src.at<char>(j, i) == (char)255) {      // (j, i)
                whiteCount++;
            }
        }
        colCounts.push_back(whiteCount);
    }
    
    
    // 绘制直方图
    Mat drawImg = Mat::zeros(src.rows, src.cols, CV_8UC1);
    for (int i = 0; i < src.cols; i++) {
        float value = (float)colCounts[i];
        line(drawImg, Point(i, src.rows), Point(i, src.rows-value), Scalar(255));
    }

    vector<vector<Point>> contours;
    vector<Vec4i> hierarchy;
    threshold(drawImg, drawImg, 0, 255, THRESH_OTSU+THRESH_BINARY);

    findContours(drawImg, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, Point(0, 0));
    vector<Rect> charsRects;
    vector<vector<Point>>::iterator itr = contours.begin();
    while (itr != contours.end()) {
        RotatedRect mr = minAreaRect((Mat)*itr);
        charsRects.push_back(mr.boundingRect());
        itr++;
    }
    
    Mat testSrc = Mat::zeros(src.rows, src.cols, CV_8UC3);
    for (int i = 0; i < charsRects.size(); i++) {
        rectangle(testSrc, charsRects[i], Scalar(0, 255, 255), 1);
    }
    
    sort(charsRects.begin(), charsRects.end(),[](Rect r1, Rect r2) {
        return r1.x < r2.x;
    });
    
    
    // 依此为: 字母的起始位置，字母的宽度
    vector<int> locs;
    
    // 有小圆点，则依此确定左右两侧字符位置，字符间隔再次确认
    // 若无小圆点，则依据字符间隔确认
    int idx = -1;
    if (charsRects.size() < 7) {    // 粘连部分过多，依据经验划分
//        cout << "rects size are not enough!" << endl;
        
        return;
    }

    // 找小圆点的矩形
    for (int i = 2; i < charsRects.size() - 1; i++) {
        if (charsRects[i].width <= 6  && charsRects[i].height <= 6
            && (charsRects[i-1].width > 10 && charsRects[i-1].height > 10)
            && ((charsRects[i+1].width > 10 || charsRects[i+1].width < 10) && charsRects[i+1].height > 10)) {
            idx = i;
            break;
        }
    }
    
    if (idx == -1) {    // 未找到
        int maxDis = -1;
        int right_idx = 0;
        for (int i = 1; i < charsRects.size(); i++) {
            // 当前字符与前一个字符的距离
            int dis = charsRects[i].x - (charsRects[i-1].x + charsRects[i-1].width);
            if (dis > maxDis) {
                maxDis = dis;
                right_idx = i;
            }
        }
        
        // 汉字特殊处理，由第二个字母反推其位置
        int space = charsRects[right_idx-1].x - (charsRects[right_idx-2].x + charsRects[right_idx-2].width);
        int zhStart = charsRects[right_idx-1].x - space - 16;
        
        locs.push_back(zhStart);
        locs.push_back(16);
        
        locs.push_back(charsRects[right_idx-1].x - 1);
        locs.push_back(charsRects[right_idx-1].width + 1);
        
        int charsNum = 2;
        for (int i = right_idx; i < charsRects.size(); i++) {
            if (charsRects[i].width <= 10 && charsRects[i].height >= 10) {  // 特殊处理 '1'
                locs.push_back(charsRects[i].x - 3);
                locs.push_back(charsRects[i].width + 6);
                charsNum++;
            } else if (charsRects[i].width > 10 && charsRects[i].height >= 10) {
        
                if (charsRects[i].width >= 30) {
                    locs.push_back(charsRects[i].x - 1);
                    locs.push_back(charsRects[i].width / 2 + 2);
                    charsNum++;
                    
                    if (charsNum == 7) {
                        break;
                    }
                    
                    int second = charsRects[i].x - 1 + charsRects[i].width / 2 + 2;
                    locs.push_back(second);
                    locs.push_back(charsRects[i].width / 2 + 2);
                    charsNum++;
                    
                } else {
                    locs.push_back(charsRects[i].x - 1);
                    locs.push_back(charsRects[i].width + 2);
                    charsNum++;
                }
            }
            
            if (charsNum == 7) {
                break;
            }
        }
        
    } else {
        // 汉字特殊处理，由第二个字母反推其位置
        int space = charsRects[idx-1].x - (charsRects[idx-2].x + charsRects[idx-2].width);
        int zhStart = charsRects[idx-1].x - space - 16;
        
        locs.push_back(zhStart);
        locs.push_back(16);
        
        locs.push_back(charsRects[idx-1].x - 1);
        locs.push_back(charsRects[idx-1].width + 2);
        
        int charsNum = 2;
        for (int i = idx+1; i < charsRects.size(); i++) {
            if (charsRects[i].width <= 10 && charsRects[i].height >= 10) {  // 特殊处理 '1'
                locs.push_back(charsRects[i].x - 3);
                locs.push_back(charsRects[i].width + 6);
                charsNum++;
            } else if (charsRects[i].width > 10 && charsRects[i].height >= 10) {
                if (charsRects[i].width >= 30) {
                    locs.push_back(charsRects[i].x - 1);
                    locs.push_back(charsRects[i].width / 2 + 2);
                    charsNum++;
                    
                    if (charsNum == 7) {
                        break;
                    }
                    int second = charsRects[i].x - 1 + charsRects[i].width / 2 + 2;
                    locs.push_back(second);
                    locs.push_back(charsRects[i].width / 2 + 2);
                    charsNum++;
                    
                } else {
                    locs.push_back(charsRects[i].x - 1);
                    locs.push_back(charsRects[i].width + 2);
                    charsNum++;
                }
            }
            
            if (charsNum == 7) {
                break;
            }
        }
    }
    
    borderVec.insert(borderVec.end(), locs.begin(), locs.end());
    
}


// 判断车牌字符尺寸(Mat)
bool NYCharacterPartition::verifyCharSizes(Mat src)
{
    // 尺寸判断
    
    
    
    return true;
}


// 将字符Mat调整为标准尺寸（提取字符类型CV_8UC1, 二值化图像）
Mat NYCharacterPartition::resizeToNormalCharSize(Mat char_mat)
{
    Mat char_resized;
    
    char_resized.create(32, 32, CV_32FC1);
    resize(char_mat, char_resized, char_resized.size(),INTER_AREA) ;
    
    return char_resized;
}






























































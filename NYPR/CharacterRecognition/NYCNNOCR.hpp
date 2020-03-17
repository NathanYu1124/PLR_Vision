//
//  NYCNNOCR.hpp
//  Tiny_dnn
//
//  Created by NathanYu on 2018/4/19.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYCNNOCR_hpp
#define NYCNNOCR_hpp

#include <iostream>
#include <map>
#include <string>
#include "tiny_dnn/tiny_dnn.h"
#include <opencv2/opencv.hpp>
#include <dirent.h>
#include <strstream>
#include <time.h>

using namespace tiny_dnn;
using namespace tiny_dnn::activation;
using namespace tiny_dnn::layers;
using namespace tiny_dnn::core;
using namespace cv;
using namespace std;

class NYCNNOCR {
    
public:    
    // 训练CNN模型  --- 训练功能待分离
    void trainCNNModel();
    
    // 识别字母和数字
    std::map<string, float> classifyCharAndNum(Mat charMat);
    
    // 识别中文
    std::map<string, float> classifyZH(Mat charMat);
    
    // 加载CNN模型
    void loadCNNModel(string charPath, string zhPath);
    
private:
    
    // 用以识别数字+字母
    network<sequential> net;
    
    // 用以识别汉字
    network<sequential> zhNet;
    
    // 获取[a,b]区间内的随机数
    int getRandomNum(int a, int b);
    
    // 旋转图像用以生成更多的数据集
    Mat rotateImage(Mat src);
    
    // 合成新的图片
    void synthesisImage(vector<Mat> &charData, int threshold);
    
    // 将Mat转化为vec_t格式
    void convert_image(Mat src, double scale, int w, int h, std::vector<vec_t> &data);
    
    // 获取训练字符数据  --- 训练功能待分离
    void getCharsData(vector<vec_t> &trainImages, vector<label_t> &trainLabels, string directory, bool needExpand);
    
    // 获取指定目录下所有文件
    void getFilesInPath(string dirPath, vector<string> &files);
    
    // Le-Net5 CNN网络模型, 训练字母+数字  --- 训练功能待分离
    void trainCharCNNModel();
    
    // 训练汉字 --- 训练功能待分离
    void trainZHCNNModel();
    
    // 数字+字母
    string kChars[34] = {
        "0", "1", "2",
        "3", "4", "5",
        "6", "7", "8",
        "9",
        /*  10  */
        "A", "B", "C",
        "D", "E", "F",
        "G", "H",       // 没有I
        "J", "K", "L",
        "M", "N",       // 没有O
        "P", "Q", "R",
        "S", "T", "U",
        "V", "W", "X",
        "Y", "Z",
        /*  24  */
    };
    
    string zhChars[31] = {
        "zh_cuan" , "zh_e"    , "zh_gan"  ,
        "zh_gan1" , "zh_gui"  , "zh_gui1" ,
        "zh_hei"  , "zh_hu"   , "zh_ji"   ,
        "zh_jin"  , "zh_jing" , "zh_jl"   ,
        "zh_liao" , "zh_lu"   , "zh_meng" ,
        "zh_min"  , "zh_ning" , "zh_qing" ,
        "zh_qiong", "zh_shan" , "zh_su"   ,
        "zh_sx"   , "zh_wan"  , "zh_xiang",
        "zh_xin"  , "zh_yu"   , "zh_yu1"  ,
        "zh_yue"  , "zh_yun"  , "zh_zang" ,
        "zh_zhe"
    };
    
    string ZH[31] = {
        "川", "鄂", "赣",
        "甘", "贵", "桂",
        "黑", "沪", "冀",
        "津", "京", "吉",
        "辽", "鲁", "蒙",
        "闽", "宁", "青",
        "琼", "陕", "苏",
        "晋", "皖", "湘",
        "新", "豫", "渝",
        "粤", "云", "藏",
        "浙"
    };
    
};




#endif /* NYCNNOCR_hpp */

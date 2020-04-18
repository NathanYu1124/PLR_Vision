//
//  NYPlateJudge.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 24/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYPlateJudge.hpp"

// SVM模型路径
//#define TRAIN_DATA_PATH "/Users/NathanYu/Desktop/svm/"

extern int count_i = 3;
extern int count_j = 18;

// 提取HOG特征
void NYPlateJudge::getHOGFeatures(Mat src, Mat &feature)
{
    // 窗口大小 128x64, 块大小 16x16，滑动步长 8x8，cell大小 8x8，方向分箱个数 3
    HOGDescriptor hog(Size(128,64), Size(16,16), Size(8,8), Size(8,8), 3);
    vector<float> descriptor;
    
    Mat trainImg = Mat(hog.winSize, CV_32S);
    resize(src, trainImg, hog.winSize);
    
    // 计算读入图片的Hog特征
    hog.compute(trainImg, descriptor, Size(8,8));
    Mat mat_feature(descriptor);
    mat_feature.copyTo(feature);
    
}

//// 根据HOG特征训练SVM模型  --- 训练功能待分离
//int NYPlateJudge::trainSVMModel()
//{
//    // SVM参数配置
//    Ptr<SVM> svm = SVM::create();
//    svm -> setType(SVM::C_SVC);
//    svm -> setKernel(SVM::RBF);
//    svm -> setDegree(0.1);
//    svm -> setGamma(0.1);
//    svm -> setCoef0(0.1);
//    svm -> setC(1);
//    svm -> setNu(0.1);
//    svm -> setP(0.1);
//    // 训练终止条件，迭代20000次，输入数据变异比率最高要求的精度是0.0001
//    svm -> setTermCriteria(CvTermCriteria(CV_TERMCRIT_ITER, 20000,0.0001));
//
//    // 车牌与非车牌标签合并
//    Mat classes;
//
//    // 车牌与非车牌数据合并
//    Mat trainingData;
//
//    Mat trainingMat;
//    vector<int> trainingLabels;
//
//    // 收集正样本
//    getPlates(trainingMat, trainingLabels);
//    // 收集负样本
//    getNoPlates(trainingMat, trainingLabels);
//
//    Mat(trainingMat).copyTo(trainingData);
//    // 转化为训练数据的32位浮点型
//    trainingData.convertTo(trainingData, CV_32FC1);
//    Mat(trainingLabels).copyTo(classes);
//
//    // 设置训练数据
//    Ptr<TrainData> tData = TrainData::create(trainingData, ROW_SAMPLE, classes);
//
//    // 训练
//    svm -> trainAuto(tData, 10, SVM::getDefaultGrid(SVM::C), SVM::getDefaultGrid(SVM::GAMMA),
//                     SVM::getDefaultGrid(SVM::P), SVM::getDefaultGrid(SVM::NU),
//                     SVM::getDefaultGrid(SVM::COEF), SVM::getDefaultGrid(SVM::DEGREE), true);
//
//    // 存储训练模型
//    string modelPath = SVM_MODEL_PATH;
//    svm -> save(modelPath);
//
//    return 0;
//}

// 判断是否是真的车牌
bool NYPlateJudge::judgeTruePlate(Mat src)
{
    // 加载SVM模型
    string modelPath = SVM_MODEL_PATH;
    Ptr<SVM> svm = SVM::load(modelPath);
    
    Mat src_svm;
    src_svm.create(36, 136, CV_32FC1);
    resize(src, src_svm, src_svm.size(),0,0,INTER_CUBIC);
    src_svm.convertTo(src_svm, CV_32FC1);
    src_svm = src_svm.reshape(1,1);
    
    // 用已知SVM模型对车牌进行预测
    int response = svm -> predict(src_svm);
    if (response == 1) {    // 是车牌
//        cout << "是车牌!" << endl;
        return true;
    } else {    // 不是车牌
//        cout << "不是车牌!" << endl;
        return false;
    }
}

// SVM进行车牌判别
vector<NYPlate> NYPlateJudge::judgePlates(vector<NYPlate> potentialVec)
{
    vector<NYPlate> platesVec;
    
    // 加载SVM模型
    string modelPath = SVM_MODEL_PATH;
    Ptr<SVM> svm = SVM::load(modelPath);    
    
    vector<NYPlate>::iterator itr = potentialVec.begin();
    while (itr != potentialVec.end()) {
        
        // 取出车牌
        NYPlate pot_plate = (NYPlate)(*itr);
        
        // 将车牌Mat转化为预测的格式
        Mat src = pot_plate.getPlateMat();
        
        if (src.empty()) {
            cout << "NYPlateLocate: 车牌Mat为空!" << endl;
        }
        
        Mat src_svm;
        src_svm.create(36, 136, CV_32FC1);
        resize(src, src_svm, src_svm.size(),0,0,INTER_CUBIC);
        // 灰度化
        cvtColor(src_svm, src_svm, COLOR_BGR2GRAY);
        // 二值化
        threshold(src_svm, src_svm, 0, 255, THRESH_OTSU + THRESH_BINARY);
        // 提取HOG特征值
        Mat feature;
        getHOGFeatures(src_svm, feature);
        feature = feature.reshape(1,1);
        
        int response = svm -> predict(feature);
        if (response == 1) {    // 是车牌
            platesVec.push_back(pot_plate);
            
            // 保存训练数据
//            string has_path = "/Users/NathanYu/Desktop/has/";
//            char buff[50];
//            sprintf(buff, "%d.jpg",count_i++);
//            string imgPath = has_path + string(buff);
//            imwrite(imgPath, pot_plate.getPlateMat());
            
        } else {    // 不是车牌
//            string no_path = "/Users/NathanYu/Desktop/no/";
//            char buff[50];
//            sprintf(buff, "%d.jpg",count_j++);
//            string imgPath = no_path + string(buff);
//            imwrite(imgPath, pot_plate.getPlateMat());
        }
        itr++;
    }
    return platesVec;
}


//// 加载待训练的车牌：正样本  --- 训练功能待分离
//void NYPlateJudge::getPlates(Mat& trainingMat, vector<int> &trainingLabels)
//{
//    // 获取文件路径
//    string dirPath = TRAIN_DATA_PATH + string("has/train/");
//    vector<string> files;
//    getFilesInPath(dirPath, files);
//
//    int counts = (int)files.size();
//    if (counts == 0) {
//        cout << "No File Found In Train Plate Directory!" << endl;
//    }
//
//    for (int i = 0; i < counts; i++) {
//        Mat src = imread(files[i].c_str(),0);   // 读取灰度图
//        threshold(src, src, 0, 255, THRESH_OTSU + THRESH_BINARY); // 二值化
//        // 提取HOG特征
//        Mat feature;
//        getHOGFeatures(src, feature);
//        // 修改图片通道和行列数, 将矩阵修改为行向量
//        feature = feature.reshape(1,1);
//        // 贴标签
//        trainingMat.push_back(feature);
//        trainingLabels.push_back(1);
//    }
//}

//// 加载待训练的非车牌：负样本  --- 训练功能待分离
//void NYPlateJudge::getNoPlates(Mat& trainingMat, vector<int> &trainingLabels)
//{
//    // 获取文件路径
//    string dirPath = TRAIN_DATA_PATH + string("no/train/");
//    vector<string> files;
//    getFilesInPath(dirPath, files);
//
//    int counts = (int)files.size();
//    if (counts == 0) {
//        cout << "No File Found In Train Plate Directory!" << endl;
//    }
//
//    for (int i = 0; i < counts; i++) {
//        Mat src = imread(files[i].c_str(),0);   // 读取灰度图
//        threshold(src, src, 0, 255, THRESH_OTSU + THRESH_BINARY);   // 二值化
//        // 提取HOG特征
//        Mat feature;
//        getHOGFeatures(src, feature);
//        // 修改通道和行列数, 将矩阵变成行向量
//        feature = feature.reshape(1,1);
//        // 贴标签
//        trainingMat.push_back(feature);
//        trainingLabels.push_back(-1);
//    }
//}




















































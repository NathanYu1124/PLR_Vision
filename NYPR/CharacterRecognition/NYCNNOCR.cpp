//
//  NYCNNOCR.cpp
//  Tiny_dnn
//
//  Created by NathanYu on 2018/4/19.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "NYCNNOCR.hpp"

void NYCNNOCR::loadCNNModel(string charPath, string zhPath)
{
    net.load(charPath);
    zhNet.load(zhPath);
}

// 识别汉字
std::map<string, float> NYCNNOCR::classifyZH(Mat charMat)
{
    vector<vec_t> data;
    convert_image(charMat, 1.0, 32, 32, data);
    
    // 识别字符及相似度
    label_t res = zhNet.predict_label(data[0]);
    float_t value = zhNet.predict_max_value(data[0]);
    
    std::map<string, float> resValue;
    resValue[ZH[(int)res]] = (float)value;
    
    return resValue;
}

// 识别字母和数字
std::map<string, float> NYCNNOCR::classifyCharAndNum(Mat charMat)
{
    vector<vec_t> data;
    convert_image(charMat, 1.0, 32, 32, data);
    
    // 识别字符及相似度
    label_t res = net.predict_label(data[0]);
    float_t value = net.predict_max_value(data[0]);
    
    std::map<string, float> resValue;
    resValue[kChars[(int)res]] = (float)value;
    
    return resValue;
}


// 获取[a,b]区间内的随机数
int NYCNNOCR::getRandomNum(int a, int b)
{
    int range = b - a + 1;
    int num = rand() % range + a;
    return num;
}

// 旋转图像用以生成更多的数据集
Mat NYCNNOCR::rotateImage(Mat src)
{
    int r = src.rows;
    int c = src.cols;
    Mat out;
    // 每次旋转获取[-4, 4]内的一个随机角度
    int angle = getRandomNum(-4, 4);
    
    Point2f center(src.cols/2, src.rows/2);
    Mat m = getRotationMatrix2D(center, angle, 1.0);
    warpAffine(src, out, m, Size(c, r));
    
    if (out.channels() > 1) {
        cvtColor(out, out, COLOR_BGR2GRAY);
    }
    
    return out;
}

// 合成新的图片
void NYCNNOCR::synthesisImage(vector<Mat> &charData, int threshold)
{
    // 每类字符图片不少于阀值，否则补足到阀值
    if (charData.size() < threshold) {
        int off = threshold - (int)charData.size();
        
        // 生成随机数种子
        srand((int)time(NULL));
        
        while (off--) {
            Mat newImg; // 合成图片
            
            // 合成图片的原图片索引
            int imgIdx = getRandomNum(0, int(charData.size())-1);
            Mat src = charData[imgIdx];
            
            // 合成新图片的操作数
            int ops = getRandomNum(1, 3);
            while (ops--) {
                newImg = rotateImage(src);
                src = newImg;
            }
            
            // 添加生成的图片
            charData.push_back(newImg);
        }
    }
}

// 将image转化为vec_t格式
void NYCNNOCR::convert_image(Mat src, double scale, int w, int h, std::vector<vec_t> &data)
{
    if (src.data == nullptr) return;
    
    cv::Mat_<uint8_t> resized;
    resize(src, resized, Size(w, h));
    vec_t d;
    
    std::transform(resized.begin(), resized.end(), std::back_inserter(d), [=](uint8_t c) {return c * scale; });
    data.push_back(d);
}

// 获取训练字符数据
void NYCNNOCR::getCharsData(vector<vec_t> &trainImages, vector<label_t> &trainLabels, string directory, bool needExpand)
{
    char  dirPath[200];
    vector<vector<string>> all_Files;   // 0~9共10类,A~Z共24类
    
    int charsClasses = 34;  // 字符类数
    all_Files.reserve(34);
    
    // 获取所有字符路径
    int sample_count = 0;            // 已有训练字符总数
    int off = 0;
    for (int i = 0; i < charsClasses; i++) {
        vector<string> files;
        
        if (i < 10) {   // 0~9
            sprintf(dirPath, "%s%d/",directory.c_str(),i);
        } else {    // A~Z
            if (i == 18) {   // 处理I缺失
                off = 1;
                sprintf(dirPath, "%s%c/",directory.c_str(),i+off+55);
            }  else if (i == 23) {  // 处理O缺失
                off = 2;
                sprintf(dirPath, "%s%c/",directory.c_str(),i+off+55);
            } else {
                sprintf(dirPath, "%s%c/",directory.c_str(),i+off+55);
            }
        }
        
        getFilesInPath(dirPath, files);
        sample_count += files.size();
        all_Files.push_back(files);
    }
    
    // 读取已有的训练集
    vector<vector<Mat>> all_chars;
    for (int i = 0; i < charsClasses; i++) {
        vector<Mat> temp;
        for (int j = 0; j < all_Files[i].size(); j++) {
            // 读取灰度字符图像
            Mat src = imread(all_Files[i][j], 0);
            temp.push_back(src);
        }
        all_chars.push_back(temp);
    }
    
    // 扩充训练集到阀值
    if (needExpand == true) {
        for (int i = 0; i < charsClasses; i++) {
            synthesisImage(all_chars[i], 1500);
        }
    }
    
    // 转换图片格式并制作数据集和标签
    for (int i = 0; i < charsClasses; i++) {
        for (int j = 0; j < all_chars[i].size(); j++) {
            
            // 转化图片格式并添加到数据集
            convert_image(all_chars[i][j], 1.0, 32, 32, trainImages);
            
            // 添加标签
            trainLabels.push_back((label_t)i);
        }
    }
}

// 获取指定目录下所有文件
void NYCNNOCR::getFilesInPath(string dirPath, vector<string> &files)
{
    struct dirent *dirp;
    DIR* dir = opendir(dirPath.c_str());
    
    string path;
    while ((dirp = readdir(dir)) != nullptr) {
        if (dirp->d_type == DT_REG) {   // 文件
            // 忽略 . 与 ..
            if (string(dirp->d_name) == "." || string(dirp->d_name) == "..") {
                continue;
            }
            
            // 忽略 .DS_Store
            if (string(dirp->d_name) == ".DS_Store") {
                continue;
            }
            
            path = dirPath + string(dirp->d_name);
            files.push_back(path);
        }
    }
    closedir(dir);
}

// Le-Net5 CNN网络模型 --- --- 训练功能待分离
void NYCNNOCR::trainCNNModel()
{
    
#define O true
#define X false
    static const bool connection[] = {
        O, X, X, X, O, O, O, X, X, O, O, O, O, X, O, O,
        O, O, X, X, X, O, O, O, X, X, O, O, O, O, X, O,
        O, O, O, X, X, X, O, O, O, X, X, O, X, O, O, O,
        X, O, O, O, X, X, O, O, O, O, X, X, O, X, O, O,
        X, X, O, O, O, X, X, O, O, O, O, X, O, O, X, O,
        X, X, X, O, O, O, X, X, O, O, O, O, X, O, O, O
    };
#undef O
#undef X
    
    network<sequential> net;
    adagrad opt;
    // 输入32*32的图片,卷积核5*5，输入一张图，输出25张图到下一层, 输出尺寸为32-5+1=28
    net << convolutional_layer(32, 32, 5, 1, 6) << relu()
    << average_pooling_layer(28, 28, 6, 2) << relu()
    << convolutional_layer(14, 14, 5, 6, 16, connection_table(connection, 6, 16)) << relu()
    << average_pooling_layer(10, 10, 16, 2) << relu()
    << convolutional_layer(5, 5, 5, 16, 120) << relu()
    << fully_connected_layer(120, 34) << softmax_layer(34);
    
    // 加载数据
    std::vector<label_t> train_labels, test_labels;
    std::vector<vec_t> train_images, test_images;
    
    // 训练集路径
    string trainImagePath = "/Users/NathanYu/Desktop/CNNDATA/CharNum/";
    // 测试集路径
    string testImagePath = "/Users/NathanYu/Desktop/test/";
    
    getCharsData(train_images, train_labels, trainImagePath, true);
    getCharsData(test_images, test_labels, testImagePath, false);
    
    
    progress_display disp(train_images.size()); // 进度显示
    timer t;
    int minibatch_size = 340;
    int num_epochs = 40;
    
    // 回调函数
    auto on_enumerate_epoch = [&]() {
        std::cout << t.elapsed() << "s elapsed." << std::endl;
        tiny_dnn::result res = net.test(test_images, test_labels);
        std::cout << "accuracy: " << (float)res.num_success / res.num_total * 100 << "%" << std::endl;
        
        disp.restart(train_images.size());
        t.restart();
    };
    
    auto on_enumerate_minibatch = [&]() {
        disp += minibatch_size;
    };
    
    std::cout << "开始训练...." << std::endl;
    // 训练
    net.train<mse>(opt, train_images, train_labels, minibatch_size, num_epochs, on_enumerate_minibatch, on_enumerate_epoch);
    std::cout << "结束训练!" << std::endl;
    
    net.test(test_images, test_labels).print_detail(std::cout);
    
    // 保存训练好的分类器
    net.save("/Users/NathanYu/Documents/Development/Tiny_dnn/CNN_MODEL.md");
}






//
//  CacheQueue.hpp
//  PLR_Vision
//
//  Created by NathanYu on 2018/5/6.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef CacheQueue_hpp
#define CacheQueue_hpp

#include <iostream>
#include <opencv2/opencv.hpp>
#include "NYPlate.hpp"
#include "NYFrame.hpp"
#include <mutex>
#include <queue>

using namespace std;
using namespace cv;

// 单例模式，视频处理帧缓存队列
class CacheQueue {
    
public:
    // 获取单例对象
    static CacheQueue* getInstance();
    
    // 添加帧到缓存队列
    void addFrameToQueue(NYFrame frame);
    
    // 获取队首缓存帧
    NYFrame getFrameFromQueue();
    
    // 缓存队列是否为空
    bool isEmpty();
    
    // 获取当前缓存的帧数
    int getCurrentFrames();
    
    // 清空缓存区
    bool clearCacheQueue();
    
private:
    CacheQueue() {}
private:
    static CacheQueue *m_pCacheQueue;   // 指向单例对象的指针
    static mutex m_mutex;   // 锁
    
    queue<NYFrame> frameQueue;        // 视频帧缓存队列
};


#endif /* CacheQueue_hpp */
























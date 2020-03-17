//
//  CacheQueue.cpp
//  PLR_Vision
//
//  Created by NathanYu on 2018/5/6.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "CacheQueue.hpp"

CacheQueue *CacheQueue::m_pCacheQueue = NULL;
mutex CacheQueue::m_mutex;

CacheQueue *CacheQueue::getInstance()
{
    if (m_pCacheQueue == NULL) {
        std::lock_guard<std::mutex> lock(m_mutex);  // 自解锁
        if (m_pCacheQueue == NULL) {
            m_pCacheQueue = new CacheQueue();
        }
    }
    return m_pCacheQueue;
}

// 队列中添加元素
void CacheQueue::addFrameToQueue(cv::Mat frame)
{
    frameQueue.push(frame);
}

// 获取队首元素
Mat CacheQueue::getFrameFromQueue()
{
    Mat out;
    if (!frameQueue.empty()) {
        out = frameQueue.front();
        frameQueue.pop();
    }
    return out;
}

bool CacheQueue::isEmpty()
{
    return frameQueue.empty();
}

int CacheQueue::getCurrentFrames()
{
    return (int)frameQueue.size();
}

void CacheQueue::addPlatesToCache(vector<NYPlate> plates)
{

    for (int i = 0; i < plates.size(); i++) {
        
        bool hasShowed = false;
        vector<NYCharacter> newChars = plates[i].getPlateChars();
        
        for (int j = (int)platesCache.size() - 1; j >= 0 ; j--) {
            vector<NYCharacter> oddChars = platesCache[j].getPlateChars();
            
            int sameCount = 0;
            for (int k = 1; k < 7; k++) {
                if (oddChars[k].getCharacterStr() == newChars[k].getCharacterStr()) {
                    sameCount++;
                }
            }
            
            if (sameCount >= 4) {   // 车牌重复出现
                hasShowed = true;
                break;
            }
        }
        
        if (!hasShowed) {
            platesCache.push_back(plates[i]);
        }
    }
}

vector<NYPlate> CacheQueue::getAllPlates()
{
    return platesCache;
}

void CacheQueue::addCarPicToCache(cv::Mat src)
{
    carCache.push(src);
}

Mat CacheQueue::getCarFromQueue()
{
    Mat out;
    if (!carCache.empty()) {
        out = carCache.front();
        carCache.pop();
    }
    return out;
}

// 清空缓存区
bool CacheQueue::clearCacheQueue()
{
    
    // 清空帧缓存
    while (!frameQueue.empty()) {
        frameQueue.pop();
    }
    
    // 清空车辆Mat缓存
    while (!carCache.empty()) {
        carCache.pop();
    }
    
    // 清空识别车牌信息缓存
    platesCache.clear();
    
    
    return true;
}













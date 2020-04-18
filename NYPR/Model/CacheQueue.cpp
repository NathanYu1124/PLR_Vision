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

// 获取单例对象
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

// 缓存队列添加帧
void CacheQueue::addFrameToQueue(NYFrame frame)
{
    frameQueue.push(frame);
}

// 获取队首缓存帧
NYFrame CacheQueue::getFrameFromQueue()
{
    NYFrame outFrame;
    if (!frameQueue.empty()) {
        outFrame = frameQueue.front();
        frameQueue.pop();
    }
    return outFrame;
}

// 缓存队列是否为空
bool CacheQueue::isEmpty()
{
    return frameQueue.empty();
}


int CacheQueue::getCurrentFrames()
{
    return (int)frameQueue.size();
}

// 清空缓存区
bool CacheQueue::clearCacheQueue()
{
    
    // 清空帧缓存
    while (!frameQueue.empty()) {
        frameQueue.pop();
    }
    
    return true;
}













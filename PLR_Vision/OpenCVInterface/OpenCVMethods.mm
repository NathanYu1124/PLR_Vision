//
//  OpenCVMethods.m
//  PlateLicenseRecognition
//
//  Created by NathanYu on 04/04/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <stdio.h>
#import "PLR_Vision-Bridging-Header.h"
#import "NSImage+OpenCV.h"
#import <iostream>
#import "NYAutoRecognize.hpp"
#import "NYPlate.hpp"

using namespace cv;
using namespace std;

NYAutoRecognize recognizer;


@implementation ImageConverter : NSObject

// OpenCV识别车牌号码
+(NSMutableDictionary *)getPlateLicense: (NSString*)imgPath svmPath: (NSString*)svmModelPath charPath: (NSString*)charModelPath zhPath: (NSString*)zhModelPath outPath: (NSString*)cachePath;
{
    // 初始化模型路径
    recognizer.setModelPath(cachePath.UTF8String, svmModelPath.UTF8String, charModelPath.UTF8String, zhModelPath.UTF8String);
    
    Mat img = imread(imgPath.UTF8String);
    // 路径中空格或汉字: 无法读取图片
    if (img.empty()) {
    
        NSLog(@"---------------------------\n");
        NSLog(@"路径中有空格或汉字: 无法读取图片!\n");
        NSMutableDictionary *emptyDict = [[NSMutableDictionary alloc] init];
        return emptyDict;
    }
    
    vector<NYPlate> plates;
    plates = recognizer.recognizePlateNumber(img);
    
    NSMutableDictionary *dict;
    NSString *license;
    if (plates.size() > 0) {
        dict = [[NSMutableDictionary alloc] init];
        
        // 识别出的车牌个数信息
        dict[@"number"] = [NSNumber numberWithInt:(int)plates.size()];
        
        // 识别出的所有车牌号码
        NSMutableArray *allLicenses = [[NSMutableArray alloc] init];
        for (int i = 0; i < plates.size(); i++) {
            license = [NSString stringWithUTF8String:plates[i].getPlateLicense().c_str()];
            [allLicenses addObject:license];
        }
        dict[@"license"] = allLicenses;
        
        // 定位出的所有车牌图像
        NSMutableArray *plateImages = [[NSMutableArray alloc] init];
        for (int i = 0; i < plates.size(); i++) {
            NSImage *tempImage = [NSImage imageWithCVMat:plates[i].getPlateMat()];
            [plateImages addObject:tempImage];
        }
        dict[@"images"] = plateImages;
        
        // 识别出的所有字符及相似度
        NSMutableArray *allLikelyArry = [[NSMutableArray alloc] init];
        for (int i = 0; i < plates.size(); i++) {
            vector<NYCharacter> allchars = plates[i].getPlateChars();
            NSMutableArray *arry = [[NSMutableArray alloc] init];
            if (allchars.size() > 0) {
                for (int j = 0; j < allchars.size(); j++) {
                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                    NSString *tempStr = [NSString stringWithUTF8String: allchars[j].getCharacterStr().c_str()];
                    // 字符
                    tempDict[@"char"] = tempStr;
                    
                    // 字符相似度
                    tempDict[@"charSim"] = [NSNumber numberWithFloat:allchars[j].getLikelyScore()];
                    
                    // 字符图像
                    tempDict[@"charImg"] = [NSImage imageWithCVMat:allchars[j].getCharacterMat()];
                    
                    [arry addObject:tempDict];
                }
            }
            [allLikelyArry addObject:arry];
        }
        dict[@"detail"] = allLikelyArry;
        
        // 识别出的所有车牌颜色
        NSMutableArray *colorArry = [[NSMutableArray alloc] init];
        for (int i = 0; i < plates.size(); i++) {
            NSString *colorStr = [NSString stringWithUTF8String:plates[i].getPlateColorStr().c_str()];
            [colorArry addObject:colorStr];
        }
        dict[@"color"] = colorArry;
        
        
//        // 在左下角绘制车牌信息
//        NSString *path = [cachePath stringByAppendingString:@"/drawcar.jpg"];
//        NSImage *original = [[NSImage alloc] initWithContentsOfFile: path];
//
//        // 绘制车牌信息
//        [original lockFocus];
//        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:24.0],
//                                    NSForegroundColorAttributeName: [NSColor yellowColor]
//                                    };
//        int i = 0;
//        for (; i < allLicenses.count; i++) {
//            NSString *plateStr = [NSString stringWithFormat:@"%@: %@",colorArry[i], allLicenses[i]];
//            NSRect drawingRect = NSMakeRect(20,20 + i * 30, 200, 30);
//            [plateStr drawInRect:drawingRect withAttributes:attributes];
//        }
//
//        // 绘制检测到的车牌个数
//        NSString *platesNum = [NSString stringWithFormat:@"车牌个数: %d",(int)plates.size()];
//        NSRect rect = NSMakeRect(20,20 + i * 30, 200, 30);
//        [platesNum drawInRect:rect withAttributes:attributes];
//        [original unlockFocus];
//
//        NSData *imgData = [original TIFFRepresentation];
//        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imgData];
//        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
//        imgData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
//        [imgData writeToFile:path atomically:NO];
        
    }
    
    return dict;
}

// OpenCV开始处理视频流
+(BOOL)startAnalyseVideo: (NSString*)videoPath svmPath: (NSString*)svmModelPath charPath: (NSString*)charModelPath zhPath: (NSString*)zhModelPath outPath: (NSString*)cachePath
{
    // 初始化模型地址
    recognizer.setModelPath(cachePath.UTF8String, svmModelPath.UTF8String, charModelPath.UTF8String, zhModelPath.UTF8String);
    
    // 是否能正常打开视频
    bool flag = true;
    
    // 处理视频: 无法打开视频则返回false
    recognizer.analyseVideo(videoPath.UTF8String, flag);
    
    return flag;
}

// OpenCV获取视频帧
+(NSMutableDictionary*)getVideoFrame
{
    CacheQueue *frameQueue = CacheQueue::getInstance();
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    
    if (!frameQueue->isEmpty()) {   // 缓存队列非空
        infoDict[@"finish"] = [NSNumber numberWithBool:NO];
        infoDict[@"analysing"] = [NSNumber numberWithBool:NO];
        
        // 获取缓存帧
        NYFrame frame = frameQueue->getFrameFromQueue();
        
        NSMutableDictionary *frameDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *platesDict = [[NSMutableDictionary alloc] init];
        
        frameDict[@"fps"] = [NSNumber numberWithInt:frame.getFPS()];
        frameDict[@"resolution"] = [NSString stringWithUTF8String:frame.getFrameResolution().c_str()];
        frameDict[@"duration"] = [NSNumber numberWithInt:frame.getTotalFrames()];
        frameDict[@"location"] = [NSNumber numberWithInt:frame.getCurrentFrame()];
        frameDict[@"oriFrameImg"] = [NSImage imageWithCVMat:frame.getOriFrameMat()];
        frameDict[@"frameImg"] = [NSImage imageWithCVMat:frame.getCurrentFrameMat()];
        frameDict[@"plates"] = platesDict;
        
        
        platesDict[@"empty"] = [NSNumber numberWithBool:YES];
        if (frame.getPlatesVec().size() > 0) {
            
            platesDict[@"empty"] = [NSNumber numberWithBool:NO];
            
            platesDict[@"number"] = [NSNumber numberWithLong:frame.getPlatesVec().size()];
            vector<NYPlate> plates = frame.getPlatesVec();
            
            // 识别出的所有车牌号码
            NSMutableArray *allLicenses = [[NSMutableArray alloc] init];
            for (int i = 0; i < plates.size(); i++) {
                NSString *license = [NSString stringWithUTF8String:plates[i].getPlateLicense().c_str()];
                [allLicenses addObject:license];
            }
            platesDict[@"license"] = allLicenses;
            
            // 定位出的所有车牌图像
            NSMutableArray *plateImages = [[NSMutableArray alloc] init];
            for (int i = 0; i < plates.size(); i++) {
                
                if (!plates[i].getPlateMat().empty()) {
                    NSImage *tempImage = [NSImage imageWithCVMat:plates[i].getPlateMat()];
                    [plateImages addObject:tempImage];
                } else{
                    platesDict[@"empty"] = [NSNumber numberWithBool:YES];
                    NSLog(@"OpenCVMethods: 未能获取到定位的车牌图像!\n");
                }
            }
            platesDict[@"images"] = plateImages;
            
            // 识别出的所有字符及相似度
            NSMutableArray *allLikelyArry = [[NSMutableArray alloc] init];
            for (int i = 0; i < plates.size(); i++) {
               vector<NYCharacter> allchars = plates[i].getPlateChars();
               NSMutableArray *arry = [[NSMutableArray alloc] init];
               if (allchars.size() > 0) {
                   for (int j = 0; j < allchars.size(); j++) {
                       NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                       NSString *tempStr = [NSString stringWithUTF8String: allchars[j].getCharacterStr().c_str()];
                       // 字符
                       tempDict[@"char"] = tempStr;
                       
                       // 字符相似度
                       tempDict[@"charSim"] = [NSNumber numberWithFloat:allchars[j].getLikelyScore()];
                       
                       // 字符图像
                       tempDict[@"charImg"] = [NSImage imageWithCVMat:allchars[j].getCharacterMat()];
                       
                       [arry addObject:tempDict];
                    }
                }
                [allLikelyArry addObject:arry];
            }
            platesDict[@"detail"] = allLikelyArry;
            
            // 识别出的所有车牌颜色
            NSMutableArray *colorArry = [[NSMutableArray alloc] init];
            for (int i = 0; i < plates.size(); i++) {
                NSString *colorStr = [NSString stringWithUTF8String:plates[i].getPlateColorStr().c_str()];
                [colorArry addObject:colorStr];
            }
            platesDict[@"color"] = colorArry;
            
        }
        
        infoDict[@"info"] = frameDict;
    } else {
        if (recognizer.isAnalysing) {   // 缓存队列为空但正在处理视频
            infoDict[@"finish"] = [NSNumber numberWithBool:NO];
            infoDict[@"analysing"] = [NSNumber numberWithBool:YES];
        } else {    // 视频处理完毕
            infoDict[@"finish"] = [NSNumber numberWithBool:YES];
        }
    }
    
    return infoDict;
}

// 停止视频处理并退出
+ (BOOL)stopAndQuit
{
    // 停止视频处理
    recognizer.stopAnalysing();
    
    return YES;
}

// 清空识别的缓存数据
+ (BOOL)clearCacheData
{
    CacheQueue *cq = CacheQueue::getInstance();
    cq -> clearCacheQueue();
    
    return YES;
}


@end
























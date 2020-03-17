//
//  OpenCVMethods.m
//  PlateLicenseRecognition
//
//  Created by NathanYu on 04/04/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/highgui.hpp>
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
    // 沙盒路径
    recognizer.OUTPUT_PATH = cachePath.UTF8String;
    
    string path = imgPath.UTF8String;
    Mat img = imread(path);
    
    // 路径中空格或汉字: 无法读取图片
    if (img.empty()) {
        NSLog(@"---------------------------");
        NSLog(@"路径中有空格或汉字: 无法读取图片!");
        NSMutableDictionary *emptyDict = [[NSMutableDictionary alloc] init];
        return emptyDict;
    }
    
    vector<NYPlate> plates;
    plates = recognizer.recognizePlateNumber(img, svmModelPath.UTF8String, charModelPath.UTF8String, zhModelPath.UTF8String);
    
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
        
        
        // 在左下角绘制车牌信息
        NSString *path = [cachePath stringByAppendingString:@"/drawcar.jpg"];
        NSImage *original = [[NSImage alloc] initWithContentsOfFile: path];
        
        // 绘制车牌信息
        [original lockFocus];
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:24.0],
                                    NSForegroundColorAttributeName: [NSColor yellowColor]
                                    };
        int i = 0;
        for (; i < allLicenses.count; i++) {
            NSString *plateStr = [NSString stringWithFormat:@"%@: %@",colorArry[i], allLicenses[i]];
            NSRect drawingRect = NSMakeRect(20,20 + i * 30, 200, 30);
            [plateStr drawInRect:drawingRect withAttributes:attributes];
        }
        
        // 绘制检测到的车牌个数
        NSString *platesNum = [NSString stringWithFormat:@"车牌个数: %d",(int)plates.size()];
        NSRect rect = NSMakeRect(20,20 + i * 30, 200, 30);
        [platesNum drawInRect:rect withAttributes:attributes];
        [original unlockFocus];
        
        NSData *imgData = [original TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imgData];
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
        imgData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
        [imgData writeToFile:path atomically:NO];
        
    }
    
    return dict;
}

// OpenCV开始处理视频流
+(BOOL)startAnalyseVideo: (NSString*)videoPath
{
    string path = videoPath.UTF8String;
    recognizer.analyseVideo(path);
    
    return true;
}

// OpenCV获取视频帧
+(NSMutableDictionary *)getVideoFrame
{
    Mat img;    
    CacheQueue *frameQueue = CacheQueue::getInstance();
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    NSImage *imgFromMat;
    
    if (!frameQueue->isEmpty()) {
        infoDict[@"finish"] = [NSNumber numberWithBool:NO];
        img = frameQueue->getFrameFromQueue();
        imgFromMat = [NSImage imageWithCVMat:img];
        
        // 更新识别出的车牌列表
        vector<NYPlate> plates = frameQueue->getAllPlates();
        NSString *license;
        
        infoDict[@"frame"] = imgFromMat;
        
        NSMutableArray *platesArry = [[NSMutableArray alloc] init];
        if (plates.size() > 0) {
            for (int i = 0; i < plates.size(); i++) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                
                // 车牌号
                license = [NSString stringWithUTF8String:plates[i].getPlateLicense().c_str()];
                dict[@"license"] = license;
                
                // 车牌图片
                NSImage *p_img = [NSImage imageWithCVMat:plates[i].getPlateMat()];
                dict[@"image"] = p_img;
                
                // 车牌颜色
                NSString *colorStr = [NSString stringWithUTF8String:plates[i].getPlateColorStr().c_str()];
                dict[@"color"] = colorStr;
                
                // 字符相似度
                vector<NYCharacter> allchars = plates[i].getPlateChars();
                NSMutableArray *arry = [[NSMutableArray alloc] init];
                if (allchars.size() > 0) {
                    for (int j = 0; j < allchars.size(); j++) {
                        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                        NSString *tempStr = [NSString stringWithUTF8String: allchars[j].getCharacterStr().c_str()];
                        
                        // 字符
                        tempDict[@"char"] = tempStr;
                        
                        // 相似度
                        tempDict[@"charSim"] = [NSNumber numberWithFloat:allchars[j].getLikelyScore()];
                        
                        // 字符图像
                        tempDict[@"charImg"] = [NSImage imageWithCVMat:allchars[j].getCharacterMat()];
                        
                        [arry addObject:tempDict];
                    }
                }
                dict[@"detail"] = arry;
                
                [platesArry addObject:dict];
            }
        }
        
        infoDict[@"info"] = platesArry;
    } else {
        infoDict[@"finish"] = [NSNumber numberWithBool:YES];
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
























//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>

@interface ImageConverter: NSObject


// OpenCV识别车牌号码
+(NSMutableDictionary*)getPlateLicense: (NSString*)imgPath svmPath: (NSString*)svmModelPath charPath: (NSString*)charModelPath zhPath: (NSString*)zhModelPath outPath: (NSString*)cachePath;

// OpenCV获取视频帧
+(NSMutableDictionary *)getVideoFrame;

// OpenCV开始处理视频流
+(BOOL)startAnalyseVideo: (NSString*)videoPath;

// 停止视频处理并退出
+(BOOL)stopAndQuit;

// 清除缓存数据
+(BOOL)clearCacheData;

@end

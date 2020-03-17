//
//  NSImage+OpenCV.h
//  PlateLicenseRecognition
//
//  Created by NathanYu on 04/04/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//


#import <AppKit/AppKit.h>

@interface NSImage (NSImage_OpenCV) {
    
}

+(NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end

//
//  Utils.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 22/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef Utils_hpp
#define Utils_hpp

#include <stdio.h>
#include <iostream>
#include <dirent.h>
#include <vector>


using namespace std;


namespace Utils {
    
    
    enum Color{
        BLUE,       // 蓝色
        YELLOW,     // 黄色
        UNKNOWN     // 未知
    };
    
    // 获取指定目录下所有文件
    void getFilesInPath(string dirPath,vector<string> &files);

};



#endif /* Utils_hpp */

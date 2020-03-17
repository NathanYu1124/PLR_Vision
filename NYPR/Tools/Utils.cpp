//
//  Utils.cpp
//  NYPlateRecognition
//
//  Created by NathanYu on 22/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#include "Utils.hpp"

namespace Utils {
  
    // 获取指定目录下所有文件
    void getFilesInPath(string dirPath, vector<string> &files)
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
  
    
}

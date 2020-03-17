## PLR Vision

PLR Vision是MacOS系统下的开源中文车牌识别系统，核心算法基于OpenCV与TinyDNN的C++接口开发，GUI界面基于Xcode使用swift开发，自娱自乐的本科毕设项目，希望大家喜欢。



#### 软件界面

![mainView](https://github.com/NathanYu1124/PLR_Vision/blob/master/Imgs/mainView.png)

**PLR Vision系统目前已经实现的功能有:**

- MacOS系统下的简洁易用的GUI界面 (Version 2.0版本已重新设计UI界面)
- 图像中的中文车牌定位及识别
- 识别车牌号的语音播报 (Version 2.0后续版本更新添加)
- 视频流中的车辆检测与跟踪 (Version 2.0后续版本更新添加)

**PLR Vision系统目前支持的中文车牌类型：**

- [x] 单行蓝牌
- [x] 单行黄牌



## 安装使用

Github上的[Release](https://github.com/NathanYu1124/PLR_Vision/releases)页面已有MacOS系统下的DMG安装包。



## 后续更新

受疫情影响，后续更新时间可能会有所延长，愿大家平安健康地度过2020这个庚子年。

* Version 2.0.0 正式版将添加 **语音播报** 功能，并完善交互逻辑。
* Version 2.0.1 将添加 **视频流处理** 功能，并优化UI界面设计。
* Version 2.0.2 将添加 **系统设置** 功能。
* Version 2.0.3 主要解决之前版本存在的bug，并完善交互逻辑。
* Version 2.0.4 将移除Version 1.0版本中的代码，并对代码进行优化。
* Version 2.0.5 将更新核心算法使用的模型文件，并大幅提升汉字识别准确率。



#### 致谢

感谢[Dribbble](https://dribbble.com/shots/6941858-Dashboard-SMART)的设计师提供的优秀的UI界面设计，得益于此我才能使PLR Vision系统的UI界面简洁美观。

感谢[EasyPR](https://github.com/liuruoze/EasyPR)的作者提供的高质量博客，正是在他的博客的帮助下，我才开发出了PLR Vision系统的雏形并在此基础上不断进行改进，最终达到了毕设项目的预期效果。

感谢[tiny-dnn](https://github.com/tiny-dnn/tiny-dnn)的作者提供的C++开源机器学习框架，得益于此我才能实现端到端车牌识别系统的简洁易用性，使项目配置更加方便。



#### 版权

PLR Vision的源代码与数据集遵循Apache v2.0协议开源。请确保在使用前了解以上协议的内容。
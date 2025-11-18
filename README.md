# Multimoding - Multi-Modal Robot Development Platform

## 项目简介 | Project Overview

这是一个基于ROS的多模态机器人开发平台，支持移动底盘、机械臂控制、传感器集成等功能。该项目由Yahboom团队开发维护，提供了从底层STM32硬件驱动到高层ROS应用的完整解决方案。

This is a ROS-based multi-modal robot development platform supporting mobile chassis, robotic arm control, sensor integration, and more. Developed and maintained by Yahboom Team, it provides a complete solution from low-level STM32 hardware drivers to high-level ROS applications.

## 支持的硬件平台 | Supported Hardware Platforms

- **计算平台 | Computing Platforms**: 
  - NVIDIA Jetson Orin
  - NVIDIA Jetson Nano
  - Raspberry Pi
  
- **微控制器 | Microcontrollers**: 
  - STM32 series with Micro-ROS support

- **传感器 | Sensors**: 
  - IMU (惯性测量单元 | Inertial Measurement Unit)
  - LiDAR (激光雷达 | Laser Distance Sensor)
  - Cameras (摄像头 | with OpenCV)
  - Encoders (编码器)

## 主要功能 | Key Features

✅ 多平台支持 (Multi-platform support)  
✅ ROS 1 & Micro-ROS 集成 (ROS 1 & Micro-ROS integration)  
✅ Docker容器化部署 (Dockerized deployment)  
✅ 完整的硬件驱动示例 (Complete hardware driver examples)  
✅ 计算机视觉集成 (Computer vision integration)  
✅ PID运动控制 (PID motion control)  
✅ 机械臂校准工具 (Robotic arm calibration)  

## 快速开始 | Quick Start

详细的仓库结构分析和开发指南，请查看：

For detailed repository structure analysis and development guide, please see:

- 📄 [中文版详细分析 | Chinese Analysis](./REPOSITORY_ANALYSIS.md)
- 📄 [English Detailed Analysis](./REPOSITORY_ANALYSIS_EN.md)
- 🤖 [AI大模型功能分析 | AI Model Analysis](./AI_MODEL_ANALYSIS.md) - **语音/文本控制系统详解**
- 📦 [Python依赖分析 | Python Dependencies](./PYTHON_DEPENDENCIES.md) - **完整依赖包清单和安装指南**

## 目录结构 | Directory Structure

```
multimoding/
├── Board_Samples/          # 开发板示例 | Board examples
│   ├── Microros_Samples/  # Micro-ROS示例 | Micro-ROS samples
│   └── STM32_Samples/     # STM32示例 | STM32 samples
├── CONFIG/                 # 配置文件 | Configuration files
├── Code/                   # 主代码 | Main code
│   ├── Orin/              # Jetson Orin平台 | Jetson Orin platform
│   ├── jetson nano_RaspberryPi/  # Nano & Pi平台
│   └── opencv/            # 视觉处理 | Vision processing
└── README.md
```

## 版本信息 | Version Info

- **当前版本 | Current Version**: V1.1.5
- **最后更新 | Last Updated**: 2025.07.09
- **维护团队 | Maintained by**: Yahboom Team

## 技术栈 | Tech Stack

- **ROS**: Robot Operating System (ROS 1)
- **Micro-ROS**: Embedded ROS for microcontrollers
- **Python**: High-level control logic
- **C/C++**: Embedded drivers and ROS nodes
- **OpenCV**: Computer vision
- **Docker**: Containerization

## 许可证 | License

请查看项目源文件了解具体许可信息。

Please refer to project source files for specific license information.

---

**开发者 | Developer**: Yahboom Team  
**仓库 | Repository**: https://github.com/yxzhang05/multimoding
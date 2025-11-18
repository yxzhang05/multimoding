# Python依赖分析 - ROSMASTER M3 PRO AI大模型系统

## 概述

本文档详细列出了ROSMASTER M3 PRO机器人AI大模型控制系统所需的所有Python依赖包，包括ROS2包、第三方库和AI模型接口。

---

## 一、核心依赖包清单

### 1.1 ROS2相关依赖

```bash
# ROS2基础包
rclpy                    # ROS2 Python客户端库
ament-index-python       # ROS2包索引工具

# ROS2消息和接口
geometry-msgs            # 几何消息（Twist, Pose等）
std-msgs                 # 标准消息（String, Bool等）
sensor-msgs              # 传感器消息（Image等）
nav2-msgs                # Nav2导航消息
tf2-ros                  # TF坐标转换
cv-bridge                # OpenCV-ROS图像转换桥接
```

### 1.2 AI模型接口

```bash
# 阿里云大模型（国内版）
dashscope                # 阿里云百炼平台SDK
openai                   # OpenAI兼容接口

# 国际版（可选）
# dify-client            # Dify平台客户端（自定义模块）
```

### 1.3 语音处理

```bash
# 语音输入/输出
pyaudio                  # 音频输入输出
webrtcvad                # 语音活动检测（VAD）
playsound                # 音频播放
wave                     # WAV文件处理

# 离线语音识别（可选）
funasr                   # 阿里达摩院离线ASR模型

# 离线语音合成（可选）
piper-tts                # 本地TTS引擎
# 或使用 piper（取决于安装方式）
```

### 1.4 视觉处理

```bash
opencv-python            # OpenCV计算机视觉库（cv2）
# 或
opencv-contrib-python    # 包含额外模块的OpenCV
```

### 1.5 系统和工具库

```bash
# 标准库（Python内置，无需安装）
os, sys, time, threading, queue, json, re
subprocess, signal, select, math, functools
datetime, hashlib, hmac, base64, ssl
urllib, http, wsgiref, _thread

# 第三方工具库
yaml                     # PyYAML - YAML配置文件解析
pygame                   # 游戏开发库（用于音频控制）
psutil                   # 系统进程和资源监控
netifaces                # 网络接口信息
websocket-client         # WebSocket客户端
requests                 # HTTP请求库
```

### 1.6 其他依赖

```bash
# 并发处理
concurrent.futures       # Python标准库（Python 3.2+自带）
```

---

## 二、按功能模块分类

### 2.1 ASR模块 (asr.py) 依赖

**必需：**
```
rclpy
pyaudio
webrtcvad
playsound
wave
pyyaml
```

**可选（根据配置）：**
```
dashscope          # 在线ASR（use_oline_asr=True）
funasr             # 离线ASR（use_oline_asr=False）
```

### 2.2 模型服务 (model_service.py) 依赖

**必需：**
```
rclpy
dashscope          # 国内版
openai             # OpenAI兼容接口
pyyaml
json
```

**可选（国际版）：**
```
dify-client        # 需要自定义安装
requests
```

### 2.3 动作执行 (action_service.py) 依赖

**必需：**
```
rclpy
cv2 (opencv-python)
cv-bridge
pygame
pyyaml
psutil
```

**ROS2消息包：**
```
geometry-msgs
sensor-msgs
nav2-msgs
std-msgs
tf2-ros
```

### 2.4 工具模块 (utils/) 依赖

**large_model_interface.py:**
```
dashscope
openai
piper-tts
funasr
pyyaml
requests
websocket-client
netifaces
base64, hashlib, hmac
```

**text_chat.py:**
```
rclpy
(仅使用标准库)
```

---

## 三、安装命令

### 3.1 使用pip安装（推荐顺序）

```bash
# 1. 更新pip
pip3 install --upgrade pip

# 2. ROS2相关（通常随ROS2安装）
sudo apt install python3-rclpy python3-ament-index-python
sudo apt install ros-humble-geometry-msgs ros-humble-std-msgs
sudo apt install ros-humble-sensor-msgs ros-humble-nav2-msgs
sudo apt install ros-humble-tf2-ros ros-humble-cv-bridge

# 3. AI模型接口
pip3 install dashscope          # 阿里云百炼
pip3 install openai             # OpenAI接口

# 4. 语音处理
pip3 install pyaudio
pip3 install webrtcvad
pip3 install playsound
# 如果需要离线ASR
pip3 install funasr
# 如果需要离线TTS
pip3 install piper-tts

# 5. 视觉处理
pip3 install opencv-python
# 或者安装带contrib模块的版本
pip3 install opencv-contrib-python

# 6. 系统工具库
pip3 install pyyaml
pip3 install pygame
pip3 install psutil
pip3 install netifaces
pip3 install websocket-client
pip3 install requests

# 7. （可选）国际版依赖
# pip3 install dify-client  # 可能需要从GitHub安装
```

### 3.2 使用requirements.txt安装

创建 `requirements.txt` 文件：

```txt
# AI Model Interface
dashscope>=1.14.0
openai>=1.0.0

# Audio Processing
pyaudio>=0.2.11
webrtcvad>=2.0.10
playsound>=1.2.2

# Vision Processing
opencv-python>=4.5.0
# opencv-contrib-python>=4.5.0  # 可选

# System Utilities
pyyaml>=5.4.0
pygame>=2.0.0
psutil>=5.8.0
netifaces>=0.11.0
websocket-client>=1.0.0
requests>=2.25.0

# Optional: Offline Models
# funasr>=0.4.0
# piper-tts>=1.0.0
```

安装命令：
```bash
pip3 install -r requirements.txt
```

### 3.3 Jetson平台特别说明

**Jetson Orin/Nano安装注意事项：**

1. **PyAudio安装可能需要额外步骤：**
```bash
sudo apt-get install portaudio19-dev python3-pyaudio
pip3 install pyaudio
```

2. **OpenCV可能已预装：**
```bash
# Jetpack通常自带OpenCV，检查版本
python3 -c "import cv2; print(cv2.__version__)"
```

3. **使用虚拟环境（推荐）：**
```bash
python3 -m venv ~/ros2_ai_env
source ~/ros2_ai_env/bin/activate
pip install -r requirements.txt
```

---

## 四、版本兼容性

### 4.1 Python版本要求

- **最低要求：** Python 3.8+
- **推荐版本：** Python 3.10（ROS2 Humble默认）
- **测试版本：** Python 3.10.x

### 4.2 ROS2版本

- **推荐：** ROS2 Humble Hawksbill
- **可能兼容：** ROS2 Foxy, Galactic（需要测试）

### 4.3 关键依赖版本

| 包名 | 最低版本 | 推荐版本 | 说明 |
|------|---------|---------|------|
| dashscope | 1.14.0 | 最新 | 阿里云API |
| openai | 1.0.0 | 最新 | OpenAI接口 |
| opencv-python | 4.5.0 | 4.8.0+ | 视觉处理 |
| pyaudio | 0.2.11 | 最新 | 音频IO |
| webrtcvad | 2.0.10 | 最新 | VAD检测 |
| pyyaml | 5.4.0 | 6.0+ | 配置文件 |
| pygame | 2.0.0 | 2.5.0+ | 音频控制 |

---

## 五、依赖安装验证

### 5.1 验证脚本

创建 `check_dependencies.py`：

```python
#!/usr/bin/env python3
"""检查所有依赖是否正确安装"""

import sys

def check_import(module_name, package_name=None):
    """尝试导入模块并报告结果"""
    if package_name is None:
        package_name = module_name
    
    try:
        __import__(module_name)
        print(f"✓ {package_name:30s} - 已安装")
        return True
    except ImportError as e:
        print(f"✗ {package_name:30s} - 未安装: {e}")
        return False

print("="*60)
print("Python依赖检查")
print("="*60)

# 核心依赖
dependencies = [
    # ROS2
    ("rclpy", "rclpy"),
    ("ament_index_python", "ament-index-python"),
    
    # AI接口
    ("dashscope", "dashscope"),
    ("openai", "openai"),
    
    # 音频处理
    ("pyaudio", "pyaudio"),
    ("webrtcvad", "webrtcvad"),
    ("playsound", "playsound"),
    ("wave", "wave (标准库)"),
    
    # 视觉处理
    ("cv2", "opencv-python"),
    
    # 工具库
    ("yaml", "pyyaml"),
    ("pygame", "pygame"),
    ("psutil", "psutil"),
    ("netifaces", "netifaces"),
    ("websocket", "websocket-client"),
    ("requests", "requests"),
]

print("\n必需依赖:")
print("-"*60)
failed = []
for module, package in dependencies:
    if not check_import(module, package):
        failed.append(package)

# 可选依赖
optional = [
    ("funasr", "funasr (离线ASR)"),
    ("piper", "piper-tts (离线TTS)"),
]

print("\n可选依赖:")
print("-"*60)
for module, package in optional:
    check_import(module, package)

print("\n" + "="*60)
if failed:
    print(f"⚠️  缺少 {len(failed)} 个必需依赖:")
    for pkg in failed:
        print(f"   - {pkg}")
    print("\n请使用以下命令安装：")
    print(f"   pip3 install {' '.join(failed)}")
    sys.exit(1)
else:
    print("✓ 所有必需依赖已安装!")
    sys.exit(0)
```

运行检查：
```bash
python3 check_dependencies.py
```

### 5.2 ROS2环境验证

```bash
# 检查ROS2环境
echo $ROS_DISTRO  # 应显示 humble 或其他版本

# 检查ROS2包
ros2 pkg list | grep -E "(geometry_msgs|sensor_msgs|nav2_msgs)"

# 测试Python导入
python3 -c "import rclpy; print('ROS2 Python OK')"
python3 -c "import cv2; print('OpenCV OK')"
python3 -c "import dashscope; print('DashScope OK')"
```

---

## 六、常见安装问题

### 6.1 PyAudio安装失败

**问题：** `ERROR: Could not build wheels for pyaudio`

**解决方案：**
```bash
# Ubuntu/Debian
sudo apt-get install portaudio19-dev python3-dev
pip3 install pyaudio

# 或使用系统包
sudo apt-get install python3-pyaudio
```

### 6.2 OpenCV导入错误

**问题：** `ImportError: libGL.so.1: cannot open shared object file`

**解决方案：**
```bash
sudo apt-get install libgl1-mesa-glx libglib2.0-0
```

### 6.3 DashScope API错误

**问题：** `ModuleNotFoundError: No module named 'dashscope'`

**解决方案：**
```bash
# 使用国内镜像加速
pip3 install dashscope -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 6.4 ROS2包导入失败

**问题：** `ModuleNotFoundError: No module named 'rclpy'`

**解决方案：**
```bash
# 确保source了ROS2环境
source /opt/ros/humble/setup.bash
# 或将其添加到 ~/.bashrc
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
```

### 6.5 权限问题

**问题：** 使用pip安装时权限被拒绝

**解决方案：**
```bash
# 方案1：使用用户安装（推荐）
pip3 install --user <package_name>

# 方案2：使用虚拟环境
python3 -m venv ~/myenv
source ~/myenv/bin/activate
pip3 install <package_name>

# 方案3：使用sudo（不推荐）
sudo pip3 install <package_name>
```

---

## 七、移植到WHEELTEC的依赖调整

### 7.1 保留的依赖

**核心AI功能（必须保留）：**
```
dashscope, openai          # AI模型接口
pyaudio, webrtcvad         # 语音识别
pyyaml, requests           # 配置和网络
opencv-python              # 视觉处理
rclpy, geometry-msgs       # ROS2核心
```

### 7.2 可删除的依赖

**机械臂相关（WHEELTEC无机械臂）：**
```
# 可以删除以下import
from arm_msgs.msg import ArmJoints, ArmJoint
from arm_interface.msg import CurJoints
```

### 7.3 需要验证的依赖

**WHEELTEC特定包（需确认）：**
```
# 检查WHEELTEC是否使用Nav2
nav2-msgs              # 如果使用Nav2则保留

# 检查WHEELTEC的导航系统
# 如果使用其他导航系统，需要安装对应的消息包
```

---

## 八、完整安装脚本

### 8.1 一键安装脚本（Ubuntu 20.04/22.04）

创建 `install_dependencies.sh`：

```bash
#!/bin/bash
set -e

echo "========================================"
echo "安装ROSMASTER M3 PRO AI依赖"
echo "========================================"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 检查ROS2环境
if [ -z "$ROS_DISTRO" ]; then
    echo -e "${RED}错误: 未检测到ROS2环境${NC}"
    echo "请先source ROS2环境: source /opt/ros/humble/setup.bash"
    exit 1
fi

echo -e "${GREEN}检测到ROS2版本: $ROS_DISTRO${NC}"

# 更新包管理器
echo "更新pip..."
pip3 install --upgrade pip

# 安装系统依赖
echo "安装系统依赖..."
sudo apt-get update
sudo apt-get install -y \
    portaudio19-dev \
    python3-dev \
    libgl1-mesa-glx \
    libglib2.0-0

# 安装ROS2 Python包（如果缺失）
echo "检查ROS2 Python包..."
sudo apt-get install -y \
    python3-rclpy \
    python3-ament-index-python \
    ros-$ROS_DISTRO-cv-bridge \
    ros-$ROS_DISTRO-geometry-msgs \
    ros-$ROS_DISTRO-sensor-msgs \
    ros-$ROS_DISTRO-std-msgs \
    ros-$ROS_DISTRO-nav2-msgs \
    ros-$ROS_DISTRO-tf2-ros

# 安装Python依赖
echo "安装Python依赖..."
pip3 install \
    dashscope \
    openai \
    pyaudio \
    webrtcvad \
    playsound \
    opencv-python \
    pyyaml \
    pygame \
    psutil \
    netifaces \
    websocket-client \
    requests

echo -e "${GREEN}安装完成!${NC}"
echo "运行检查脚本验证安装:"
echo "  python3 check_dependencies.py"
```

使用方法：
```bash
chmod +x install_dependencies.sh
./install_dependencies.sh
```

### 8.2 Docker环境（可选）

创建 `Dockerfile`：

```dockerfile
FROM ros:humble

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3-pip \
    portaudio19-dev \
    python3-pyaudio \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# 安装Python依赖
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt

# 设置工作目录
WORKDIR /workspace

CMD ["/bin/bash"]
```

构建和使用：
```bash
docker build -t ros2-ai .
docker run -it --rm ros2-ai
```

---

## 九、依赖管理最佳实践

### 9.1 使用虚拟环境

```bash
# 创建虚拟环境
python3 -m venv ~/ros2_ai_env

# 激活环境
source ~/ros2_ai_env/bin/activate

# 安装依赖
pip install -r requirements.txt

# 每次使用前激活
source ~/ros2_ai_env/bin/activate
source /opt/ros/humble/setup.bash
```

### 9.2 固定版本号

在 `requirements.txt` 中使用精确版本：
```txt
dashscope==1.14.1
openai==1.3.5
opencv-python==4.8.1.78
```

### 9.3 定期更新

```bash
# 检查过期包
pip list --outdated

# 更新特定包
pip install --upgrade dashscope

# 导出当前环境
pip freeze > requirements-lock.txt
```

---

## 十、总结

### 10.1 核心依赖（必需）

```
✓ ROS2基础: rclpy, ament-index-python
✓ AI模型: dashscope, openai
✓ 语音处理: pyaudio, webrtcvad, playsound
✓ 视觉处理: opencv-python, cv-bridge
✓ 工具库: pyyaml, pygame, psutil, requests
```

### 10.2 总安装命令（快速版）

```bash
# 一行命令安装所有依赖
pip3 install dashscope openai pyaudio webrtcvad playsound opencv-python pyyaml pygame psutil netifaces websocket-client requests
```

### 10.3 验证安装

```bash
# 快速测试所有关键导入
python3 << EOF
import rclpy
import dashscope
import pyaudio
import webrtcvad
import cv2
import yaml
print("✓ 所有核心依赖可用!")
EOF
```

---

**文档版本：** V1.0  
**最后更新：** 2025-11-18  
**适用系统：** Ubuntu 20.04/22.04, ROS2 Humble  
**硬件平台：** Jetson Orin NX, Jetson Nano, x86_64

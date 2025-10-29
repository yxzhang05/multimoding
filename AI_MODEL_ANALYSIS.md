# ROSMASTER M3 PRO AI大模型功能分析报告

## 概述

该文档详细分析了ROSMASTER M3 PRO机器人中基于AI大模型的语音和文本控制系统，重点针对`Code/Orin/M3Pro_ws/src/largemodel`包的实现。该系统可实现通过自然语言（语音或文本）控制机器人执行导航、机械臂操作等复杂任务。

---

## 一、系统架构

### 1.1 整体架构图

```
用户输入 (语音/文本)
    ↓
ASR模块 (asr.py) ────→ 语音识别转文字
    ↓
模型服务层 (model_service.py)
    ├─ 决策层AI (规划任务步骤)
    ├─ 执行层AI (生成动作序列)
    └─ 多模态支持 (文本+图像)
    ↓
动作执行层 (action_service.py)
    ├─ 导航控制 (navigation)
    ├─ 机械臂控制 (arm control)
    ├─ 视觉处理 (seewhat)
    └─ 基础运动 (move, turn, stop)
    ↓
ROS2底层控制
    ├─ /cmd_vel (速度控制)
    ├─ Nav2 (导航)
    └─ 机械臂驱动
```

### 1.2 核心ROS2包结构

**主要包：**
- `largemodel` - 核心AI控制包（语音+移动底盘）
- `largemodel_arm` - 机械臂专用AI控制
- `text_chat` - 纯文本交互界面

---

## 二、核心模块详解

### 2.1 ASR模块 (asr.py)

**功能：** 语音唤醒 + 语音识别 + 语音活动检测(VAD)

**关键特性：**
```python
# 初始化组件
- 语音唤醒检测 (KWS - Keyword Spotting)
- WebRTC VAD (Voice Activity Detection) - 区分人声与噪音
- ASR引擎 (支持在线/离线)
```

**工作流程：**
1. **唤醒检测** → 串口麦克风监听唤醒词
2. **录音** → VAD检测说话结束，保存为`user_speech.wav`
3. **ASR识别** → 调用ASR引擎转文字
4. **发布结果** → 通过`/asr` topic发布识别文本

**支持的ASR引擎：**
- **中国版：** 阿里云通义千问 Paraformer实时语音识别
- **国际版：** 讯飞ASR (XUN-FEI)

**ROS Topics：**
```yaml
发布者:
  - /asr (String) - 识别的文本结果
  - /wakeup (Bool) - 唤醒信号
  - /record_status (Bool) - 录音状态
  - /beep (UInt16) - 蜂鸣器控制
```

**配置参数 (yahboom.yaml):**
```yaml
asr:
  VAD_MODE: 2                    # VAD灵敏度 (0-3)
  sample_rate: 16000             # 采样率
  use_oline_asr: True            # 在线/离线ASR
  mic_serial_port: "/dev/mic"    # 麦克风串口
  language: 'zh'                 # 语言设置
```

---

### 2.2 模型服务层 (model_service.py)

**核心功能：** AI大模型推理引擎，负责理解用户意图并生成机器人动作序列

#### 2.2.1 双层大模型架构（可选）

当`use_double_llm=True`时启用：

**决策层AI：**
- 功能：任务规划和步骤拆解
- 输入：用户原始指令
- 输出：结构化的执行步骤描述
- 模型：通过Dify或通义千问

**执行层AI：**
- 功能：将规划转换为具体的机器人动作序列
- 输入：决策层的规划 + 当前环境（可选图像）
- 输出：JSON格式的动作列表
- 模型：多模态大模型 (qwen-vl-max)

#### 2.2.2 单层模型架构（默认）

直接用执行层大模型处理用户指令，生成动作序列。

#### 2.2.3 动作序列格式

**标准JSON输出格式：**
```json
{
  "action": [
    ["navigation", "kitchen"],
    ["seewhat"],
    ["navigation", "bedroom"],
    ["stop"]
  ],
  "response": "好的，我会先去厨房看看，然后返回卧室"
}
```

**支持的动作类型：**
| 动作名称 | 参数 | 说明 |
|---------|------|------|
| `navigation` | 地点名称 | 导航到指定位置 |
| `seewhat` | - | 拍照并识别当前场景 |
| `move` | 距离(m) | 前进/后退 |
| `turn` | 角度(度) | 旋转 |
| `stop` | - | 停止所有动作 |
| `arm_grab` | 颜色 | 抓取指定颜色物体 |
| `arm_place` | - | 放置物体 |

#### 2.2.4 多模态能力

支持文本+图像混合输入：
```python
# 文本输入
model_service.instruction_process(prompt="去厨房", type="text")

# 图像输入（用于seewhat动作）
model_service.instruction_process(
    prompt="看到了什么", 
    type="image",
    image_path="/path/to/image.png"
)
```

**ROS Topics：**
```yaml
订阅者:
  - /asr (String) - 来自ASR的文本输入
  - /actionstatus (String) - 动作执行状态反馈

发布者:
  - /action_goal (Rot.Goal) - 发送动作序列到执行层
  - /text_response (String) - AI回复（文本模式）
```

**配置参数：**
```yaml
model_service:
  language: 'zh'                      # 中文/英文
  regional_setting: "China"           # China/international
  text_chat_mode: False               # 文本/语音模式
```

---

### 2.3 动作执行层 (action_service.py)

**功能：** ROS2 Action Server，负责解析动作列表并逐步执行

#### 2.3.1 核心方法

**1. 导航 (navigation)**
```python
def navigation(self, point_name):
    # 从map_mapping.yaml加载目标点坐标
    # 调用Nav2进行路径规划和导航
    # 支持打断和状态反馈
```

**2. 视觉识别 (seewhat)**
```python
def seewhat(self):
    # 订阅相机图像
    # 保存当前帧为image.png
    # 调用多模态大模型识别场景
    # 返回识别结果
```

**3. 移动控制 (move, turn)**
```python
def move(self, distance):
    # 发布/cmd_vel控制速度
    # 线速度：distance > 0前进，< 0后退
    
def turn(self, angle):
    # 发布/cmd_vel控制旋转
    # 角速度：angle > 0左转，< 0右转
```

**4. 机械臂控制**
```python
def arm_grab(self, color):
    # 启动颜色识别+抓取
    
def arm_place():
    # 放置物体
```

#### 2.3.2 动作打断机制

系统支持新唤醒打断当前任务：
```python
def wakeup_callback(self, msg):
    if msg.data:
        self.interrupt_flag = True  # 设置打断标志
        self.stop()                 # 停止所有运动
        # 终止当前语音播放
```

#### 2.3.3 状态反馈

每个动作执行后发布状态：
```python
self.actionstatus_pub.publish(
    String(data="navigation_success: 已到达厨房")
)
```

**ROS Topics：**
```yaml
订阅者:
  - /camera/color/image_raw (Image) - 相机图像
  - /wakeup (Bool) - 唤醒打断信号
  
发布者:
  - /cmd_vel (Twist) - 速度控制
  - /actionstatus (String) - 状态反馈
  - /beep (UInt16) - 蜂鸣器
  
Action Server:
  - /action_service (Rot) - 接收动作序列
  
Action Client:
  - /navigate_to_pose (NavigateToPose) - Nav2导航
```

---

### 2.4 文本交互模块 (text_chat.py)

**功能：** 提供命令行文本交互界面（替代语音输入）

**使用场景：**
- 调试和测试
- 无麦克风环境
- 需要精确控制输入

**工作流程：**
```
用户在终端输入文本
    ↓
发布到 /asr topic (模拟ASR输出)
    ↓
等待AI处理
    ↓
显示加载动画 "let me think..."
    ↓
接收 /text_response 显示结果
```

**启动方式：**
```bash
ros2 launch largemodel largemodel_control.launch.py text_chat_mode:=True
```

---

## 三、AI大模型配置

### 3.1 国内版配置 (中国用户)

#### 主要依赖平台
- **阿里云百炼大模型平台**
- **通义千问系列模型**

#### 配置文件 (large_model_interface.yaml)

```yaml
# 必须配置项
tongyi_api_key: "sk-xxxxx"                    # 阿里云API密钥
tongyi_app_id: 'app-xxxxx'                    # 应用ID
multimodel: "qwen-vl-max-2025-04-08"          # 执行层多模态模型

# ASR配置
oline_asr_sample_rate: 16000
oline_asr_model: 'paraformer-realtime-v2'

# TTS配置
tts_supplier: "aliyun"                        # aliyun/baidu
oline_tts_model: "cosyvoice-v2"
voice_tone: "longwan_v2"                      # 语音音色

# 可选：百度语音合成
baidu_API_KEY: ''
baidu_SECRET_KEY: ''
```

#### 推荐模型组合
| 功能 | 模型 | 说明 |
|------|------|------|
| ASR | paraformer-realtime-v2 | 实时语音识别 |
| TTS | cosyvoice-v2 | 语音合成 |
| 执行层AI | qwen-vl-max-2025-04-08 | 多模态理解 |
| 决策层AI | qwen-plus/qwen-max | 任务规划 |

---

### 3.2 国际版配置

#### 主要依赖平台
- **Dify平台** (作为中间件)
- **本地离线模型**

#### 配置文件

```yaml
# Dify API配置
decision_AI_api_key: "app-xxxxx"      # 决策层应用
execution_AI_api_key: "app-xxxxx"    # 执行层应用

# 本地TTS模型
tts_language: "en"
en_tts_model: "/home/jetson/MODELS/tts/en/en_US-libritts-high.onnx"

# 本地ASR模型
local_asr_model: "/home/jetson/MODELS/asr/SenseVoiceSmall"
```

---

## 四、地图映射配置

### 4.1 map_mapping.yaml

用于将自然语言地点名映射到实际导航坐标：

```yaml
# 示例配置
kitchen:
  x: 2.5
  y: 1.3
  z: 0.0
  orientation:
    x: 0.0
    y: 0.0
    z: 0.707
    w: 0.707

bedroom:
  x: -1.2
  y: 3.5
  ...
```

### 4.2 使用示例

**用户指令：** "去厨房"
**AI输出：** `["navigation", "kitchen"]`
**执行：** 查询`kitchen`坐标 → 导航

---

## 五、依赖库和工具

### 5.1 Python依赖

```python
# ROS2相关
import rclpy
from geometry_msgs.msg import Twist
from sensor_msgs.msg import Image
from nav2_msgs.action import NavigateToPose

# AI模型接口
from utils.large_model_interface import model_interface

# 语音处理
import pyaudio
import webrtcvad
from playsound import playsound

# 视觉处理
import cv2
from cv_bridge import CvBridge

# 其他
import yaml
import threading
```

### 5.2 外部服务

**中国版：**
- 阿里云DashScope API
- 通义千问大模型
- CosyVoice TTS

**国际版：**
- Dify平台
- 本地Piper TTS
- 本地SenseVoice ASR

---

## 六、启动和使用

### 6.1 启动命令

**语音交互模式：**
```bash
cd ~/M3Pro_ws
source install/setup.bash
ros2 launch largemodel largemodel_control.launch.py
```

**文本交互模式：**
```bash
ros2 launch largemodel largemodel_control.launch.py text_chat_mode:=True
```

### 6.2 使用流程

#### 语音模式
1. 说出唤醒词（由麦克风检测）
2. 听到"我在"应答后说出指令
3. 等待AI处理并执行
4. 观察机器人动作和语音反馈

#### 文本模式
1. 在终端输入指令
2. 等待AI思考（显示动画）
3. 查看AI回复和动作序列
4. 观察执行状态反馈

### 6.3 示例交互

**示例1：简单导航**
```
用户: "去厨房"
AI: "好的，我现在去厨房"
动作: [["navigation", "kitchen"], ["stop"]]
```

**示例2：多步骤任务**
```
用户: "去卧室看看有什么，然后回到客厅"
AI: "明白了，我会先去卧室查看，然后返回客厅"
动作: [
  ["navigation", "bedroom"],
  ["seewhat"],
  ["navigation", "living_room"],
  ["stop"]
]
```

**示例3：机械臂任务**
```
用户: "抓取红色的物体"
AI: "好的，我会帮你抓取红色物体"
动作: [["arm_grab", "red"], ["stop"]]
```

---

## 七、移植到WHEELTEC机器人的关键步骤

### 7.1 核心可移植组件

**必须移植：**
1. ✅ `largemodel/largemodel/` - 核心AI逻辑
   - `asr.py` - 语音识别模块
   - `model_service.py` - AI推理引擎
   - `action_service.py` - 动作执行框架
   - `text_chat.py` - 文本交互（可选）

2. ✅ `largemodel/utils/` - 工具库
   - `large_model_interface.py` - AI API封装
   - `promot.py` - Prompt模板
   - `dify_client2.py` - Dify客户端（国际版）

3. ✅ `largemodel/config/` - 配置文件
   - `yahboom.yaml` - ROS参数配置
   - `large_model_interface.yaml` - AI模型配置
   - `map_mapping.yaml` - 地图点位映射

**不需要移植：**
- ❌ 机械臂相关代码（WHEELTEC无机械臂）
- ❌ M3Pro特定的硬件接口

### 7.2 需要适配的部分

#### 1. 速度控制Topic
```python
# M3 PRO
Speed_topic: "/cmd_vel"

# WHEELTEC - 需确认实际topic名称
Speed_topic: "/cmd_vel"  # 或其他名称
```

#### 2. 导航系统
```python
# M3 PRO使用Nav2
self.navclient = ActionClient(self, NavigateToPose, "navigate_to_pose")

# WHEELTEC - 确认导航action名称
# 如果使用Nav2，可直接复用
# 如果使用其他导航系统，需要适配
```

#### 3. 相机Topic
```python
# 修改image_topic参数为WHEELTEC的相机topic
image_topic: "/camera/color/image_raw"  # 改为WHEELTEC相机
```

#### 4. TF坐标系
```python
# 检查并修改坐标系名称
self.tf_buffer.lookup_transform("map", "base_footprint", ...)
# WHEELTEC可能使用base_link等其他名称
```

#### 5. 删除机械臂相关代码

在`action_service.py`中注释或删除：
```python
# 删除这些方法
# def arm_grab(self, color):
# def arm_place(self):
# def arm_grasp_init(self):

# 从动作列表中移除
# "arm_grab", "arm_place", "arm_*"
```

### 7.3 配置文件修改

**yahboom.yaml适配：**
```yaml
action_service:
  ros__parameters:
    Speed_topic: "/cmd_vel"              # 改为WHEELTEC的速度topic
    image_topic: "/camera/rgb/image_raw" # 改为WHEELTEC的相机topic
    # 其他保持不变
```

**map_mapping.yaml适配：**
```yaml
# 录制WHEELTEC环境的地图点位
# 使用WHEELTEC的导航工具获取坐标
kitchen:
  x: [实际X坐标]
  y: [实际Y坐标]
  ...
```

### 7.4 测试步骤

**阶段1：语音识别测试**
```bash
# 单独测试ASR模块
ros2 run largemodel asr
# 说话测试，查看/asr topic输出
ros2 topic echo /asr
```

**阶段2：AI模型测试**
```bash
# 测试模型服务
ros2 run largemodel model_service
# 发布测试文本
ros2 topic pub /asr std_msgs/String "data: '去厨房'"
```

**阶段3：集成测试**
```bash
# 完整启动
ros2 launch largemodel largemodel_control.launch.py text_chat_mode:=True
# 输入指令测试
```

### 7.5 潜在问题和解决方案

| 问题 | 解决方案 |
|------|---------|
| WHEELTEC导航系统不兼容 | 编写导航适配器，封装WHEELTEC导航API |
| 相机图像格式不同 | 使用cv_bridge转换，适配不同的image encoding |
| TF坐标系命名不同 | 修改代码中的坐标系名称或使用tf static transform |
| ROS2版本差异 | 检查ROS2版本兼容性，必要时升级依赖 |

---

## 八、关键文件清单

### 8.1 核心代码文件

```
Code/Orin/M3Pro_ws/src/largemodel/
├── largemodel/
│   ├── asr.py                    # 【核心】语音识别主程序
│   ├── model_service.py          # 【核心】AI模型服务
│   ├── action_service.py         # 【核心】动作执行服务器
│   └── __init__.py
├── utils/
│   ├── large_model_interface.py  # 【核心】AI API接口封装
│   ├── promot.py                 # 【核心】Prompt工程
│   ├── dify_client2.py           # Dify客户端
│   └── mic_serial.py             # 麦克风串口控制
├── config/
│   ├── yahboom.yaml              # 【必须】ROS节点参数
│   ├── large_model_interface.yaml # 【必须】AI模型配置
│   └── map_mapping.yaml          # 【必须】地图点位映射
├── launch/
│   └── largemodel_control.launch.py # 【必须】启动文件
└── package.xml                    # ROS包清单
```

### 8.2 移植优先级

**P0 (最高优先级):**
- `asr.py` - 语音输入
- `model_service.py` - AI推理
- `action_service.py` - 动作执行
- `large_model_interface.py` - API接口
- `yahboom.yaml` - 配置
- `large_model_interface.yaml` - AI配置

**P1 (中等优先级):**
- `text_chat.py` - 文本交互（调试用）
- `promot.py` - Prompt模板
- `map_mapping.yaml` - 地图映射

**P2 (低优先级):**
- `mic_serial.py` - 如果使用USB麦克风可忽略
- `dify_client2.py` - 仅国际版需要

---

## 九、性能优化建议

### 9.1 响应速度优化

1. **使用流式响应**
   ```python
   # 大模型支持流式输出时，边生成边执行
   for token in model.stream_generate():
       process_action(token)
   ```

2. **并行处理**
   ```python
   # 导航时可以并行进行下一步的AI规划
   with concurrent.futures.ThreadPoolExecutor():
       future = executor.submit(model_inference)
   ```

3. **缓存常用Prompt**
   ```python
   # 预编译常用指令的prompt
   self.prompt_cache = {}
   ```

### 9.2 资源管理

1. **模型加载优化**
   - 启动时预加载模型
   - 使用模型量化减少显存

2. **内存管理**
   ```python
   # 及时释放大图像数据
   del image_data
   gc.collect()
   ```

---

## 十、常见问题FAQ

### Q1: 如何更换AI模型？
**A:** 修改`large_model_interface.yaml`中的模型名称：
```yaml
multimodel: "qwen-vl-max-2025-04-08"  # 改为其他支持的模型
```

### Q2: 语音识别不准确怎么办？
**A:** 
1. 调整VAD灵敏度：`VAD_MODE: 2` (范围0-3)
2. 使用在线ASR：`use_oline_asr: True`
3. 检查麦克风质量和环境噪音

### Q3: 如何添加新的动作类型？
**A:** 在`action_service.py`中：
```python
# 1. 添加执行方法
def my_new_action(self, param):
    # 实现逻辑
    pass

# 2. 在execute_callback中添加分支
elif action_type == "my_new_action":
    self.my_new_action(params)

# 3. 更新Prompt告诉AI可用的动作
```

### Q4: WHEELTEC没有Nav2怎么办？
**A:** 需要适配WHEELTEC的导航接口：
```python
# 创建导航适配器
class WheeltecNavigationAdapter:
    def navigate_to_pose(self, x, y, theta):
        # 调用WHEELTEC的导航API
        pass
```

---

## 十一、总结

### 核心优势
1. ✅ **自然语言控制** - 无需记忆命令，直接对话
2. ✅ **多模态理解** - 支持文本+图像输入
3. ✅ **任务规划能力** - AI自动拆解复杂任务
4. ✅ **可扩展架构** - 易于添加新动作类型
5. ✅ **双语支持** - 中英文切换

### 移植关键点
1. **保留核心逻辑** - ASR、AI推理、动作框架
2. **适配接口** - 速度控制、导航、相机topic
3. **删除冗余** - 机械臂相关代码
4. **配置调整** - Topic名称、坐标系、地图点位
5. **渐进测试** - 分模块测试，逐步集成

### 建议移植路径
```
1. 搭建开发环境 (ROS2 + Python依赖)
    ↓
2. 配置AI模型API (阿里云/Dify)
    ↓
3. 移植并测试ASR模块
    ↓
4. 移植并测试AI模型服务
    ↓
5. 适配WHEELTEC导航接口
    ↓
6. 集成测试和调优
```

---

**文档版本：** V1.0  
**最后更新：** 2025-10-29  
**作者：** GitHub Copilot AI Agent  
**适用于：** ROSMASTER M3 PRO → WHEELTEC机器人移植

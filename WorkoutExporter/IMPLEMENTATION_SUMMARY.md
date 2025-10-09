# WorkoutExporter iOS应用 - 本地HTML热力图集成

## 概述

我已经成功为你的WorkoutExporter iOS应用添加了加载本地`workout.html`文件的功能。现在应用有两种热力图显示方式：

1. **查看热力图** - 从HealthKit读取实际健身数据生成的热力图
2. **本地HTML热力图** - 显示预设运动数据的cal-heatmap.js热力图

## 新增文件

### 1. LocalHtmlViewController.swift
- 专门用于加载和显示本地HTML文件的视图控制器
- 使用WKWebView加载`workout.html`文件
- 包含错误处理和加载指示器
- 支持刷新功能

### 2. HTML_INTEGRATION.md
- 详细的集成说明文档
- 包含故障排除指南

### 3. copy_html_to_xcode.sh
- 自动化脚本，帮助复制HTML文件到Xcode项目

## 修改的文件

### ViewController.swift
- 添加了"本地HTML热力图"按钮
- 更新了UI布局约束
- 添加了导航到LocalHtmlViewController的功能

### workout.html
- 修改了HTML文档结构，添加了正确的DOCTYPE和meta标签
- 将D3.js库从HTTP改为HTTPS以确保iOS兼容性
- 添加了正确的HTML闭合标签

## 使用步骤

### 第一步：将文件添加到Xcode项目

1. 运行复制脚本（可选）：
   ```bash
   ./copy_html_to_xcode.sh
   ```

2. 在Xcode中：
   - 打开`WorkoutExporter.xcodeproj`
   - 右键点击项目导航器中的"WorkoutExporter"文件夹
   - 选择"Add Files to 'WorkoutExporter'"
   - 选择以下文件：
     - `workout.html`
     - `cal-heatmap.js`
     - `cal-heatmap.css`（如果存在）
   - 确保勾选：
     - ✅ "Copy items if needed"
     - ✅ "Add to target: WorkoutExporter"

### 第二步：运行应用

1. 在Xcode中构建并运行应用
2. 在主界面点击"本地HTML热力图"按钮
3. 应用将加载并显示workout.html文件

## 技术特点

### WebView配置
- 启用JavaScript执行
- 允许内联媒体播放
- 使用`loadFileURL`方法加载本地文件
- 允许访问同目录下的资源文件

### 错误处理
- 文件不存在时显示友好错误信息
- 网络加载失败时的错误提示
- 加载状态指示器

### 用户体验
- 导航栏刷新按钮
- 加载指示器
- 清晰的错误信息

## 注意事项

1. **网络依赖**：HTML文件需要网络连接来加载在线JavaScript库
2. **文件路径**：确保所有引用的文件都在同一目录下
3. **iOS兼容性**：使用HTTPS协议加载外部资源
4. **权限**：应用会自动处理本地文件访问权限

## 故障排除

如果遇到问题：

1. 检查文件是否正确添加到Xcode项目Bundle中
2. 确认文件名大小写正确
3. 检查网络连接
4. 查看Xcode控制台的详细错误信息

## 功能对比

| 功能 | 查看热力图 | 本地HTML热力图 |
|------|------------|----------------|
| 数据源 | HealthKit实时数据 | 预设示例数据 |
| 样式 | 自定义CSS | cal-heatmap.js |
| 交互性 | 基本显示 | 丰富的交互功能 |
| 网络需求 | 无 | 需要（加载D3.js） |
| 自定义性 | 高 | 中等 |

现在你的iOS应用已经可以完美显示workout.html文件了！
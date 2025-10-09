# 在WorkoutExporter iOS应用中加载workout.html

## 步骤说明

### 1. 将HTML文件添加到Xcode项目

要在iOS应用中显示`workout.html`文件，需要将以下文件添加到Xcode项目的Bundle中：

1. **workout.html** - 主HTML文件
2. **cal-heatmap.js** - JavaScript库文件
3. **cal-heatmap.css** - 样式文件（如果存在）

### 2. 在Xcode中添加文件的步骤

1. 打开`WorkoutExporter.xcodeproj`
2. 右键点击项目导航器中的`WorkoutExporter`文件夹
3. 选择"Add Files to 'WorkoutExporter'"
4. 选择以下文件：
   - `workout.html`
   - `cal-heatmap.js`
   - `cal-heatmap.css`（如果存在）
5. 确保在添加文件时勾选：
   - ✅ "Copy items if needed"
   - ✅ "Add to target: WorkoutExporter"

### 3. 验证文件是否正确添加

在Xcode项目导航器中，你应该能看到这些文件已经添加到项目中。

### 4. 使用应用

1. 运行应用
2. 点击"本地HTML热力图"按钮
3. 应用将加载并显示`workout.html`文件

### 5. 注意事项

- **网络依赖**：`workout.html`文件引用了在线的D3.js库(`http://d3js.org/d3.v3.min.js`)，确保设备有网络连接
- **文件路径**：HTML文件中引用的`cal-heatmap.js`使用相对路径，确保该文件与HTML文件在同一目录
- **权限**：应用使用`loadFileURL`方法加载本地文件，这允许访问同目录下的资源文件

### 6. 故障排除

如果HTML文件无法加载：

1. 检查文件是否正确添加到项目Bundle中
2. 检查文件名是否正确（区分大小写）
3. 检查网络连接（用于加载在线JavaScript库）
4. 查看Xcode控制台的错误信息

### 7. 代码结构

- `LocalHtmlViewController.swift` - 负责加载和显示本地HTML文件
- `ViewController.swift` - 主界面，包含导航到HTML视图的按钮
- `HeatmapViewController.swift` - 原有的热力图视图控制器（使用HealthKit数据）

### 8. 功能对比

- **本地HTML热力图**：显示预设的运动数据，使用cal-heatmap.js库
- **查看热力图**：从HealthKit读取实际的健身数据并生成热力图
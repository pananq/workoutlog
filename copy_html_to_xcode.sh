#!/bin/bash

# 将HTML文件复制到Xcode项目的脚本
# 使用方法: ./copy_html_to_xcode.sh

echo "正在将HTML文件复制到Xcode项目..."

# 定义源文件路径
SOURCE_DIR="."
XCODE_PROJECT_DIR="./WorkoutExporter"

# 要复制的文件列表
FILES_TO_COPY=(
    "workout.html"
    "cal-heatmap.js"
    "cal-heatmap.css"
)

# 检查Xcode项目目录是否存在
if [ ! -d "$XCODE_PROJECT_DIR" ]; then
    echo "错误: 找不到Xcode项目目录 $XCODE_PROJECT_DIR"
    exit 1
fi

# 复制文件
for file in "${FILES_TO_COPY[@]}"; do
    if [ -f "$SOURCE_DIR/$file" ]; then
        cp "$SOURCE_DIR/$file" "$XCODE_PROJECT_DIR/"
        echo "✅ 已复制: $file"
    else
        echo "⚠️  文件不存在: $file"
    fi
done

echo ""
echo "文件复制完成！"
echo ""
echo "接下来的步骤："
echo "1. 在Xcode中打开 WorkoutExporter.xcodeproj"
echo "2. 右键点击项目导航器中的 'WorkoutExporter' 文件夹"
echo "3. 选择 'Add Files to WorkoutExporter'"
echo "4. 选择刚才复制的文件："
for file in "${FILES_TO_COPY[@]}"; do
    echo "   - $file"
done
echo "5. 确保勾选 'Copy items if needed' 和 'Add to target: WorkoutExporter'"
echo "6. 点击 'Add' 完成添加"
echo ""
echo "然后就可以运行应用并点击 '本地HTML热力图' 按钮了！"
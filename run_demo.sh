#!/bin/bash

# 检查 Flutter 环境
echo "1. 检查 Flutter 环境..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter"
    exit 1
fi

echo "✅ Flutter 版本: $(flutter --version | head -1)"

# 获取依赖
echo ""
echo "3. 获取依赖..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 依赖获取失败"
    exit 1
fi

echo "✅ 依赖获取成功"

# 检测 设备
echo ""
echo "4. 检测 设备..."
TIZEN_DEVICES=$(flutter-tizen devices --machine | jq -r '.[] | select(.sdk | contains("Tizen")) | "\(.name) (\(.id))"' 2>/dev/null)

if [ -z "$TIZEN_DEVICES" ]; then
    echo "❌ 未检测到 设备"
    exit 1
else
    echo "✅ 检测到 设备:"
    echo "$TIZEN_DEVICES"
fi

echo ""
echo "5. 运行中 ..."
flutter-tizen run

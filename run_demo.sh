#!/bin/bash

echo "=== IPTV 频道管理器 - GetX + Drift Demo ==="
echo ""

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

# 检测可用设备
echo ""
echo "4. 检测可用设备..."
DEVICES=$(flutter devices --machine | jq -r '.[] | select(.platform != "web") | "\(.name) (\(.id))"' 2>/dev/null)

if [ -z "$DEVICES" ]; then
    echo "⚠️  未检测到可用设备"
    echo ""
    echo "可用的选项："
    echo "- Android 设备连接并启用开发者模式"
    echo "- iOS 设备连接并信任"
    echo "- Android/iOS 模拟器运行中"
    echo "- Tizen 设备连接"
    echo ""
    echo "将尝试运行默认设备..."
else
    echo "✅ 检测到设备:"
    echo "$DEVICES"
fi

# 选择设备运行
echo ""
echo "5. 选择运行平台:"
echo "1) Android"
echo "2) iOS"
echo "3) Tizen ⭐ (推荐测试)"
echo "4) Windows (桌面)"
echo "5) macOS (桌面)"
echo "6) Linux (桌面)"
echo ""
echo "💡 提示："
echo "- Tizen 平台需要先安装 flutter-tizen"
echo "- 如果选择 Tizen，请确保 Tizen Studio 已安装"
echo ""

read -p "请选择 (1-6，默认3): " choice
choice=${choice:-3}  # 默认选择Tizen

case $choice in
    1)
        echo "🚀 运行 Android 版本..."
        flutter run
        ;;
    2)
        echo "🚀 运行 iOS 版本..."
        flutter run
        ;;
    3)
        echo "🚀 运行 Tizen 版本..."
        if ! command -v flutter-tizen &> /dev/null; then
            echo "❌ flutter-tizen 未安装"
            echo ""
            echo "安装步骤："
            echo "1. 安装 Tizen Studio: https://developer.tizen.org/development/tizen-studio"
            echo "2. 运行: flutter pub global activate flutter_tizen"
            echo ""
            read -p "是否继续尝试运行其他平台？(y/n): " try_other
            if [[ $try_other == "y" || $try_other == "Y" ]]; then
                flutter run
            else
                echo "退出"
                exit 1
            fi
        else
            flutter-tizen run
        fi
        ;;
    4)
        echo "🚀 运行 Windows 桌面版本..."
        flutter run -d windows
        ;;
    5)
        echo "🚀 运行 macOS 桌面版本..."
        flutter run -d macos
        ;;
    6)
        echo "🚀 运行 Linux 桌面版本..."
        flutter run -d linux
        ;;
    *)
        echo "❌ 无效选择，使用默认 Tizen 平台..."
        flutter-tizen run 2>/dev/null || flutter run
        ;;
esac

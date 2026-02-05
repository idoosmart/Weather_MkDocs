#!/bin/bash

# 检查 Python 是否安装
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误: 未找到 Python 3。请先安装 Python 3。"
    exit 1
fi

# 检查 pip 是否安装
if ! command -v pip3 &> /dev/null; then
    echo "❌ 错误: 未找到 pip3。请安装 pip3。"
    exit 1
fi

echo "🔍 检查 MkDocs 依赖..."

# 检查 mkdocs-material 是否安装
if ! pip3 show mkdocs-material &> /dev/null; then
    echo "📦 正在安装 mkdocs-material..."
    pip3 install mkdocs-material
else
    echo "✅ mkdocs-material 已安装"
fi

# 检查 mkdocs-static-i18n 是否安装
if ! pip3 show mkdocs-static-i18n &> /dev/null; then
    echo "📦 正在安装 mkdocs-static-i18n..."
    pip3 install mkdocs-static-i18n
else
    echo "✅ mkdocs-static-i18n 已安装"
fi


echo "📝 准备文档目录..."
rm -rf docs
mkdir -p docs
# 将 USAGE.md 作为中文首页
cp USAGE.md docs/index.md
# 将 USAGE_EN.md 作为英文首页
cp USAGE_EN.md docs/index.en.md

echo "🚀 启动本地预览服务器..."
echo "👉 请在浏览器访问: http://127.0.0.1:8000"
echo "⌨️  按 Ctrl+C 停止服务器"
echo ""

# 启动服务器
if command -v mkdocs &> /dev/null; then
    mkdocs serve
else
    python3 -m mkdocs serve
fi

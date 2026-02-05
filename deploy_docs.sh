#!/bin/bash

# 检查 mkdocs 是否安装
if ! command -v mkdocs &> /dev/null; then
    echo "❌ 错误: 未找到 mkdocs 命令。"
    echo "请运行 ./preview_docs.sh 安装依赖，或手动运行: pip3 install mkdocs-material mkdocs-static-i18n"
    exit 1
fi

echo "📦 准备发布..."

# 准备文档目录 (与服务端逻辑一致)
rm -rf docs
mkdir -p docs
echo "📝 复制中文文档 -> docs/index.md"
cp USAGE.md docs/index.md
echo "📝 复制英文文档 -> docs/index.en.md"
cp USAGE_EN.md docs/index.en.md

echo "🚀 开始构建并推送到 gh-pages 分支..."
# mkdocs gh-deploy 会自动构建并提交到 gh-pages 分支
mkdocs gh-deploy --force

echo "✅ 发布完成！"
echo "👉 请访问 GitHub Pages 查看更新。"

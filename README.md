# Weather SDK Documentation

此仓库包含 **IDOWeatherSDK** 的官方文档构建源码。

## 项目简介

本文档项目使用 **MkDocs** 和 **Material for MkDocs** 主题构建，支持中文与英文双语切换。

- **源项目**: [IDOWeatherSDK](https://github.com/IDOWeatherSDK/IDOWeatherSDK)
- **文档预览**: [GitHub Pages Link](https://idoosmart.github.io/Weather_MkDocs/) (请根据实际 Pages 地址修改)

## 目录结构

```text
.
├── USAGE.md               # 中文文档源文件 (SDK 使用指南)
├── USAGE_EN.md            # 英文文档源文件 (English Guide)
├── mkdocs.yml             # MkDocs 站点配置文件
├── preview_docs.sh        # 本地预览辅助脚本
├── deploy_docs.sh         # 本地发布辅助脚本
└── .github
    └── workflows
        └── publish-docs.yml # GitHub Actions 自动部署配置
```

## 如何贡献/修改文档

**注意**: 请勿直接修改 `docs/` 目录！该目录是构建过程中自动生成的。

1.  **修改内容**：
    *   中文内容请编辑 `USAGE.md`
    *   英文内容请编辑 `USAGE_EN.md`

2.  **本地预览**：
    运行以下脚本可自动安装依赖并启动本地服务器：
    ```bash
    ./preview_docs.sh
    ```
    访问 `http://127.0.0.1:8000` 查看效果。

3.  **提交更改**：
    提交并推送到 `main` 分支：
    ```bash
    git push origin main
    ```
    GitHub Actions 会自动构建并将静态网站发布到 `gh-pages` 分支。

## 环境依赖 (手动安装)

如果你不使用辅助脚本，可以手动安装以下 Python 依赖：

```bash
pip install mkdocs-material mkdocs-static-i18n
```

## 许可证

MIT License

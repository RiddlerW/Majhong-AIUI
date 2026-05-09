# AIUI 项目 Code Wiki

> **项目仓库**: [https://github.com/jsar-project/AIUI](https://github.com/jsar-project/AIUI)
> **许可证**: Apache License 2.0
> **版本**: 1.0.0 (jsui-dev-tools)
> **生成日期**: 2026-05-09

---

## 目录

- [1. 项目概述](#1-项目概述)
- [2. 整体架构](#2-整体架构)
- [3. 仓库目录结构](#3-仓库目录结构)
- [4. 主要模块职责](#4-主要模块职责)
  - [4.1 packages/create-aiui-agent — CLI 脚手架工具](#41-packagescreate-aiui-agent--cli-脚手架工具)
  - [4.2 samples/simple — 示例应用](#42-samplessimple--示例应用)
  - [4.3 skills/aiui-dev — AI Agent 技能文档](#43-skillsaiui-dev--ai-agent-技能文档)
  - [4.4 .github/workflows — CI/CD 自动化](#44-githubworkflows--cicd-自动化)
- [5. AIUI 应用核心概念](#5-aiui-应用核心概念)
  - [5.1 项目文件体系](#51-项目文件体系)
  - [5.2 单文件组件 (.ink) 规范](#52-单文件组件-ink-规范)
  - [5.3 WXML 模板语法](#53-wxml-模板语法)
  - [5.4 WXSS 样式系统](#54-wxss-样式系统)
  - [5.5 事件系统](#55-事件系统)
- [6. 内置组件参考](#6-内置组件参考)
- [7. API 参考](#7-api-参考)
  - [7.1 Canvas API](#71-canvas-api)
  - [7.2 wx 命名空间 API](#72-wx-命名空间-api)
  - [7.3 Crypto API](#73-crypto-api)
- [8. 设计规范](#8-设计规范)
- [9. 依赖关系](#9-依赖关系)
- [10. 项目运行方式](#10-项目运行方式)
- [11. 关键类与函数说明](#11-关键类与函数说明)

---

## 1. 项目概述

**AIUI**（Artificial Intelligence User Interface）是一个面向带显示屏 AI 眼镜的 **Agentic Runtime**。本仓库 `jsar-project/AIUI` 提供了用于构建 AIUI 应用的开发工具、CLI 以及 AI Agent 技能文档，使开发者能够构建智能、交互式且上下文感知的 Agent 应用。

核心定位：
- **Agentic Runtime**：AIUI 不是传统的前端框架，而是一个为 AI Agent 设计的运行时环境
- **面向 AI 眼镜**：专为带显示屏的智能眼镜设备优化
- **MCP UI 组件模型**：每个页面都是一个 Model Context Protocol (MCP) UI 组件
- **AI 优先开发**：提供完整的 AI Agent 技能文档，使 LLM 能够直接生成 AIUI 代码

---

## 2. 整体架构

```
┌──────────────────────────────────────────────────────────────┐
│                     AIUI 生态系统架构                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐    ┌─────────────────────────────────┐  │
│  │  CLI 脚手架工具   │    │      AI Agent 技能文档           │  │
│  │  create-aiui-   │    │      skills/aiui-dev/            │  │
│  │  agent          │    │  ┌───────┐ ┌──────┐ ┌─────┐     │  │
│  │                 │    │  │SKILL  │ │compo- │ │apis │     │  │
│  │  npm create     │    │  │.md    │ │nents  │ │.md  │     │  │
│  │  @yodaos-pkg/   │    │  │       │ │.md    │ │     │     │  │
│  │  aiui-agent     │    │  └───────┘ └──────┘ └─────┘     │  │
│  └────────┬────────┘    └──────────────┬──────────────────┘  │
│           │                            │                      │
│           ▼                            ▼                      │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  AIUI 应用项目                           │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────────┐  │ │
│  │  │AGENTS.md │ │ app.json │ │  app.js   │ │  pages/   │  │ │
│  │  │Agent声明  │ │ 全局配置  │ │ 生命周期  │ │ .ink 页面  │  │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └───────────┘  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                            │                                  │
│                            ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              AIUI Runtime (Ink 引擎)                     │ │
│  │  ┌────────────┐ ┌──────────────┐ ┌──────────────────┐   │ │
│  │  │ WXML 渲染器 │ │ WXSS 样式引擎 │ │ JS 运行时 (ESM)  │   │ │
│  │  └────────────┘ └──────────────┘ └──────────────────┘   │ │
│  │  ┌────────────┐ ┌──────────────┐ ┌──────────────────┐   │ │
│  │  │ 内置组件库  │ │ Canvas 2D API │ │ wx 命名空间 API  │   │ │
│  │  └────────────┘ └──────────────┘ └──────────────────┘   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                            │                                  │
│                            ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │           AI 眼镜设备 (带显示屏)                          │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

---

## 3. 仓库目录结构

```
AIUI/
├── .github/
│   └── workflows/
│       └── daily-build.yml          # 每日自动构建与发布工作流
├── packages/
│   └── create-aiui-agent/           # npm CLI 脚手架工具
│       ├── index.js                 # CLI 入口脚本
│       ├── package.json             # 包配置 (@yodaos-pkg/create-aiui-agent)
│       └── template/                # 项目模板目录
│           ├── AGENTS.md            # Agent 声明模板
│           ├── app.js               # 应用生命周期模板
│           ├── app.json             # 全局配置模板
│           ├── package.json         # 项目 package.json 模板
│           └── pages/
│               └── index/
│                   └── index.ink    # 首页 SFC 模板
├── samples/
│   └── simple/                      # 完整示例应用
│       ├── .aixignore               # 构建忽略文件
│       ├── AGENTS.md                # Agent 声明
│       ├── app.js                   # 应用入口
│       ├── app.json                 # 全局配置 (31个页面)
│       ├── app.wxss                 # 全局样式
│       ├── assets/                  # 静态资源
│       │   ├── avatar.jpg
│       │   ├── clear-day.svg
│       │   ├── elephant.png
│       │   └── mixkit-arcade-retro-game-over-213.wav
│       ├── lib/                     # 辅助模块
│       └── pages/                   # 31个示例页面
│           ├── index/               # 首页
│           ├── a2ui/                # A2UI 动态渲染
│           ├── audio/               # 音频播放
│           ├── box_shadow/          # 盒阴影
│           ├── calendar/            # 日历
│           ├── canvas/              # Canvas 绘图
│           ├── canvas_api/          # Canvas API 演示
│           ├── card/                # 卡片布局
│           ├── chart/               # 图表
│           ├── css_vars/            # CSS 变量
│           ├── error_state/         # 错误状态
│           ├── filter/              # CSS 滤镜
│           ├── font_styling/        # 字体样式
│           ├── font_weight/         # 字体粗细
│           ├── grid/                # 网格布局
│           ├── image/               # 图片
│           ├── input_textarea/      # 输入框/文本域
│           ├── layout/              # 布局
│           ├── list/                # 列表
│           ├── lottie/              # Lottie 动画
│           ├── media_query/         # 媒体查询
│           ├── opacity/             # 透明度
│           ├── open/                # 打开/导航
│           ├── outline/             # 轮廓
│           ├── position/            # 定位
│           ├── row_column/          # 行列布局
│           ├── size_constraints/    # 尺寸约束
│           ├── streamdown/          # 流式文本
│           ├── switch/              # 开关
│           ├── transform/           # 变换
│           └── transition_animation/ # 过渡动画
├── skills/
│   └── aiui-dev/                    # AI Agent 技能文档
│       ├── SKILL.md                 # 主开发指南
│       ├── components.md            # 内置组件参考
│       └── apis.md                  # API 参考
├── .gitignore
├── package.json                     # 根项目配置
├── package-lock.json
├── README.md                        # 英文文档
└── README.zh-CN.md                  # 中文文档
```

---

## 4. 主要模块职责

### 4.1 packages/create-aiui-agent — CLI 脚手架工具

**职责**: 提供命令行工具，快速生成 AIUI Agent 项目模板。

| 属性 | 值 |
|---|---|
| npm 包名 | `@yodaos-pkg/create-aiui-agent` |
| 版本 | 2.1.2 |
| 入口文件 | `index.js` |
| CLI 命令 | `npx @yodaos-pkg/create-aiui-agent <project-name>` |

**核心逻辑** (`index.js`):

```javascript
#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const targetDirName = process.argv[2];
// 1. 验证参数
// 2. 检查目标目录是否已存在
// 3. 递归复制 template/ 目录到目标位置
// 4. 替换模板中的 {{PROJECT_NAME}} 占位符
```

**关键函数**:

| 函数 | 说明 |
|---|---|
| `copyDir(src, dest)` | 递归复制模板目录，同时替换 `{{PROJECT_NAME}}` 占位符 |

**模板文件说明**:

| 模板文件 | 用途 | 占位符 |
|---|---|---|
| `template/AGENTS.md` | Agent 声明文件 | `{{PROJECT_NAME}}` |
| `template/app.json` | 全局配置 | `{{PROJECT_NAME}}` (navigationBarTitleText) |
| `template/app.js` | 应用生命周期 | 无 |
| `template/package.json` | 项目配置 | `{{PROJECT_NAME}}` (name) |
| `template/pages/index/index.ink` | 首页 SFC | 无 |

**生成的项目结构**:

```
my-agent/
├── AGENTS.md
├── app.js
├── app.json
├── package.json
└── pages/
    └── index/
        └── index.ink
```

---

### 4.2 samples/simple — 示例应用

**职责**: 提供完整的可运行示例应用，展示 AIUI 的功能特性和常见 UI 模式。

**应用配置** (`app.json`):

| 配置项 | 值 |
|---|---|
| 页面数量 | 31 个 |
| 导航栏标题 | "Ink Demo" |
| 视口宽度 | device-width |

**应用生命周期** (`app.js`):

```javascript
export default {
  onLaunch: function () { /* 应用启动 */ },
  onShow: function () { /* 应用显示 */ },
  onHide: function () { /* 应用隐藏 */ },
  globalData: { hasLogin: false }
};
```

**全局样式** (`app.wxss`):

使用 CSS 变量系统定义主题：
- `--theme-color`: 主题色 (默认 `#3498db`)
- `--theme-bg`: 主题背景色
- `--theme-border`: 主题边框
- `--theme-radius`: 主题圆角 (默认 `12px`)
- `--theme-padding`: 主题内边距 (默认 `20px`)

**示例页面分类**:

| 分类 | 页面 | 说明 |
|---|---|---|
| 布局与定位 | `layout`, `grid`, `position`, `row_column`, `size_constraints` | 布局模式与定位策略 |
| UI 基础组件 | `image`, `list`, `input_textarea`, `switch`, `card` | 常用 UI 构建块 |
| 渲染与视觉 | `canvas`, `canvas_api`, `chart`, `lottie` | 绘图与视觉内容 |
| 样式与响应式 | `media_query`, `css_vars`, `filter`, `transform`, `opacity`, `box_shadow`, `outline` | 样式与视觉效果 |
| 字体与文本 | `font_styling`, `font_weight`, `streamdown` | 文字排版与流式文本 |
| 交互与动画 | `transition_animation`, `a2ui` | 交互与动态 UI |
| 功能演示 | `audio`, `calendar`, `error_state`, `open` | 特定功能演示 |

**静态资源** (`assets/`):

| 文件 | 类型 | 用途 |
|---|---|---|
| `avatar.jpg` | 图片 | 头像示例 |
| `clear-day.svg` | SVG | 天气图标 |
| `elephant.png` | 图片 | 图片展示示例 |
| `mixkit-arcade-retro-game-over-213.wav` | 音频 | 音频播放示例 |

---

### 4.3 skills/aiui-dev — AI Agent 技能文档

**职责**: 为 LLM / AI 编码助手提供完整的 AIUI 开发上下文，使其能够正确生成 AIUI 代码。

**包含文件**:

| 文件 | 内容 | 用途 |
|---|---|---|
| `SKILL.md` | 主开发指南 | 项目结构、.ink SFC 规范、WXML/WXSS 语法、设计规范、事件系统 |
| `components.md` | 内置组件参考 | 18 个内置组件的属性、事件、内容模型与示例 |
| `apis.md` | API 参考 | Canvas 2D API、wx 命名空间 API 的完整实现文档 |

**安装方式**:

```bash
npx skills add https://github.com/jsar-project/AIUI/tree/main/skills/aiui-dev
```

**SKILL.md 前置元数据**:

```yaml
---
name: "aiui-dev"
description: "Specialized agent for developing AIUI applications..."
---
```

---

### 4.4 .github/workflows — CI/CD 自动化

**职责**: 自动化每日构建与 npm 发布。

**工作流**: `daily-build.yml`

| 配置项 | 值 |
|---|---|
| 名称 | Daily Build |
| 触发条件 | `workflow_dispatch` (手动) + `schedule` (cron: `0 0 * * *`，每日 UTC 0点) |
| 运行环境 | `ubuntu-latest` |
| Node.js 版本 | 20 |
| 发布目标 | `@yodaos-pkg/create-aiui-agent` → npmjs.org (public) |
| 认证方式 | `NODE_AUTH_TOKEN` (GitHub Secrets) |

---

## 5. AIUI 应用核心概念

### 5.1 项目文件体系

一个标准的 AIUI 应用项目包含以下核心文件：

```
my-agent/
├── AGENTS.md          # Agent 声明文件
├── app.json           # 全局配置
├── app.js             # 应用生命周期
├── app.wxss           # 全局样式 (可选)
├── pages/             # 页面目录
│   └── index/
│       └── index.ink  # 页面 SFC
└── assets/            # 静态资源
```

#### AGENTS.md — Agent 声明

定义 Agent 的身份、权限和技能：

```markdown
# Agent Manifest
## Identity
- **Name**: My AIUI Agent
- **Version**: 1.0.0
- **Description**: 应用描述
- **Author**: 开发者名称
## Capabilities
- **Permissions**: camera, microphone, network, audio
- **Skills**: weather-lookup
```

#### app.json — 全局配置

```json
{
  "pages": ["pages/index/index"],
  "window": {
    "navigationBarTitleText": "My AIUI Agent",
    "viewport": { "width": "device-width" }
  }
}
```

关键字段：
- `pages`: 页面路径数组，第一个为首页
- `window.navigationBarTitleText`: 导航栏标题
- `window.viewport.width`: 视口宽度

#### app.js — 应用生命周期

```javascript
export default {
  onLaunch() { /* 应用启动时调用 */ },
  onShow() { /* 应用显示时调用 */ },
  onHide() { /* 应用隐藏时调用 */ },
  globalData: { /* 全局共享数据 */ }
};
```

#### page.json / `<script def>` — 页面配置

每个页面作为 MCP UI 组件，配置包括：

```json
{
  "navigationBarTitleText": "Weather Card",
  "description": "页面功能描述",
  "schema": {
    "data": {
      "type": "object",
      "properties": {
        "city": { "type": "string" },
        "temperature": { "type": "number" }
      },
      "required": ["city", "temperature"]
    }
  }
}
```

---

### 5.2 单文件组件 (.ink) 规范

`.ink` 文件是 AIUI 推荐的页面开发格式，将配置、逻辑、模板和样式集中在一个文件中。

**四大标签块**:

| 标签 | 用途 | 格式 |
|---|---|---|
| `<script def>` | 页面级 JSON 配置 | JSON 对象 |
| `<script setup>` | 页面 JS 逻辑 | ES Module (`export default`) |
| `<page>` | 页面模板结构 | WXML 语法 |
| `<style>` | 页面样式 | CSS/WXSS |

**完整示例**:

```html
<script def>
{
  "navigationBarTitleText": "Home"
}
</script>
<script setup>
import wx from 'wx';
export default {
  data: {
    greeting: 'Hello AIUI!'
  },
  onLoad() {
    console.log('Page loaded');
  },
  handleTap() {
    this.setData({ greeting: 'Hello, World!' });
  }
}
</script>
<page>
  <view class="container">
    <text class="title">{{ greeting }}</text>
    <button bindtap="handleTap">Click Me</button>
  </view>
</page>
<style>
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
}
.title {
  font-size: 24px;
  margin-bottom: 20px;
}
</style>
```

**页面逻辑对象** (`<script setup>` 中的 `export default`):

| 属性/方法 | 类型 | 说明 |
|---|---|---|
| `data` | Object | 页面响应式数据 |
| `onLoad()` | Function | 页面加载生命周期 |
| `onShow()` | Function | 页面显示生命周期 |
| `onHide()` | Function | 页面隐藏生命周期 |
| `onKeyDown(event)` | Function | 硬件按键按下事件 |
| `onKeyUp(event)` | Function | 硬件按键释放事件 |
| `this.setData(obj)` | Method | 更新页面数据并触发视图刷新 |
| 自定义方法 | Function | 通过 `bindtap` 等绑定到模板事件 |

---

### 5.3 WXML 模板语法

#### 数据绑定

```html
<view>{{ message }}</view>
<view class="{{ dynamicClass }}"></view>
<view>{{ count + 1 }}</view>
```

#### 条件渲染

```html
<view ink:if="{{condition === 1}}">条件1</view>
<view ink:elif="{{condition === 2}}">条件2</view>
<view ink:else>其他</view>
```

#### 列表渲染

```html
<view ink:for="{{cities}}" ink:key="name">
  <text>{{item.name}}</text>
  <text>{{item.temperature}}</text>
</view>
```

- `item`: 当前元素
- `index`: 当前索引
- `ink:key`: 推荐提供稳定的 key

> **限制**: 当前不支持嵌套 `ink:for`，需要先在 JavaScript 中展平数据。

---

### 5.4 WXSS 样式系统

WXSS 高度兼容标准 CSS，并扩展了移动/可穿戴设备特性。

**支持的特性**:

| 特性 | 说明 |
|---|---|
| `@import` | 导入外部样式表 |
| Class 选择器 | `.class` (推荐) |
| ID 选择器 | `#id` |
| 类型选择器 | `element` |
| 组合器 | 分组 (`A, B`)、后代 (`A B`)、子代 (`A > B`) |
| Flexbox | 完整支持，推荐布局方式 |
| CSS 变量 | 支持 `var(--name)` |

**全局样式示例** (`app.wxss`):

```css
:root {
  --theme-color: var(--color-primary, #3498db);
  --theme-radius: var(--radius-md, 12px);
  --theme-padding: var(--spacing-lg, 20px);
}
```

---

### 5.5 事件系统

#### 组件级事件

| 事件属性 | 说明 |
|---|---|
| `bindtap` | 点击事件 (冒泡) |
| `catchtap` | 点击事件 (阻止冒泡) |
| `bindinput` | 输入事件 |
| `bindchange` | 值变更事件 |

#### 页面级事件

```javascript
export default {
  onKeyDown(event) { /* 硬件按键按下 */ },
  onKeyUp(event) { /* 硬件按键释放 */ }
}
```

---

## 6. 内置组件参考

AIUI 提供 18 个内置组件，映射到原生实现以获得最佳性能。

### 组件总览

| 组件 | 用途 | 特有属性 | 特有事件 |
|---|---|---|---|
| `<view>` | 基础布局容器 | — | `bindtap`, `catchtap` |
| `<swiper>` | 滑动容器 (当前为 view 别名) | — | — |
| `<swiper-item>` | 滑动项 (当前为 view 别名) | — | — |
| `<fragment>` | 分组容器 (当前为 view 别名) | — | — |
| `<text>` | 文本显示 | — | — |
| `<icon>` | 图标 (当前为 text 别名) | — | — |
| `<image>` | 图片显示 | `src`, `mode` | — |
| `<button>` | 按钮 | — | `bindtap`, `catchtap` |
| `<canvas>` | 2D 绘图 | `width`, `height` | — |
| `<scroll-view>` | 滚动容器 | `scroll-x`, `scroll-y`, `scroll-top`, `scroll-left`, `scroll-into-view`, `auto-scroll`, `scroll-speed`, `scroll-direction` | — |
| `<chart>` | 图表 | `type`, `series`, `data`, `width`, `height`, `animate`, `color`, `show-average`, `smooth`, `y-axis`, `x-axis` | — |
| `<input>` | 单行输入 | `value`, `placeholder`, `disabled`, `maxLength` | `bindinput` |
| `<textarea>` | 多行输入 | `value`, `placeholder`, `disabled`, `maxLength` | `bindinput` |
| `<switch>` | 开关 | `checked`, `disabled`, `type`, `color` | `bindchange` |
| `<lottie-view>` | Lottie 动画 | `src`, `auto-play`, `loop`, `speed`, `progress` | — |
| `<streamdown>` | 流式文本 | `content`, `streaming` | — |
| `<a2ui>` | 动态 UI 渲染 | `commands` | — |
| `<error-state>` | 错误状态 | — | — |

### 组件别名关系

```
swiper      → view 实现
swiper-item → view 实现
fragment    → view 实现
icon        → text 实现
```

### 关键组件详细说明

#### `<image>`

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `src` | String | `''` | 图片源路径或 URL |
| `mode` | String | `scaleToFill` | 缩放模式；`widthFix` 按宽度等比缩放，`heightFix` 按高度等比缩放 |

#### `<scroll-view>`

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `scroll-x` | Boolean | `false` | 水平滚动 |
| `scroll-y` | Boolean | `false` | 垂直滚动 |
| `scroll-top` | Number | `0` | 垂直滚动偏移 |
| `scroll-left` | Number | `0` | 水平滚动偏移 |
| `scroll-into-view` | String | — | 滚动到指定 id 的子节点 |
| `auto-scroll` | Boolean | `false` | 自动滚动动画 |
| `scroll-speed` | Number | `25.0` | 自动滚动速度 |
| `scroll-direction` | String | `vertical` | 自动滚动方向 (`vertical`/`horizontal`) |

#### `<chart>`

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `type` | String | `line` | 图表类型: `line`, `area`, `pie`, `radar` |
| `series` | String/Array | `value` | 数据系列配置 |
| `data` | Array | `[]` | 数据源 |
| `width` | Number | `300` | 画布宽度 |
| `height` | Number | `150` | 画布高度 |
| `animate` | Boolean | `false` | 动画更新 |
| `color` | String | `#00FF7F` | 主色 |
| `smooth` | Boolean | `true` | 平滑曲线 |
| `show-average` | Boolean | `false` | 显示平均线 |
| `y-axis` | Object/String | — | Y 轴配置 |
| `x-axis` | Object/String | — | X 轴配置 |

#### `<input>`

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `value` | String | `''` | 当前值 |
| `placeholder` | String | `''` | 占位文本 |
| `disabled` | Boolean | `false` | 禁用 |
| `maxLength` | Number | — | 最大字符数 |

事件: `bindinput` — 每次按键触发，`event.detail.value` 包含更新后的字符串。

#### `<textarea>`

与 `<input>` 相同的属性和事件，支持多行输入和换行。

#### `<switch>`

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `checked` | Boolean | `false` | 开关状态 |
| `disabled` | Boolean | `false` | 禁用 |
| `type` | String | `switch` | `checkbox` 渲染为复选框样式 |
| `color` | String | `#04C160` | 选中颜色 |

事件: `bindchange` — 值切换后触发，`event.detail.value` 为新的布尔状态。

#### `<lottie-view>`

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `src` | String | `''` | Lottie 源 (内联 JSON/本地路径/HTTP URL) |
| `auto-play` | Boolean | `true` | 自动播放 |
| `loop` | Boolean | `true` | 循环播放 |
| `speed` | Number | `1.0` | 播放速度 |
| `progress` | Number | — | 手动进度控制 (0.0-1.0) |

#### `<streamdown>`

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `content` | String | `''` | Markdown 风格内容 |
| `streaming` | Boolean | `false` | 显示流式光标 |

#### `<a2ui>`

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `commands` | String | — | A2UI 命令 JSON，首次渲染时执行一次 |

---

## 7. API 参考

### 7.1 Canvas API

AIUI 提供了完整的 Canvas 2D 绘图 API，与实现严格对齐。

#### 入口方式

**方式一：脚本自有 Canvas**

```javascript
const canvas = new Canvas(300, 150);
const ctx = canvas.getContext('2d');
```

**方式二：页面 Canvas 节点**

```javascript
import wx from 'wx';
const ctx = wx.createCanvasContext('chartCanvas');
```

> `canvas.getContext(type)` 仅接受 `'2d'`，其他值返回 `null`。

#### CanvasRenderingContext2D

**样式属性**:

| 属性 | 说明 |
|---|---|
| `fillStyle` | 填充样式 (颜色字符串/CanvasGradient/CanvasPattern) |
| `strokeStyle` | 描边样式 |
| `lineWidth` | 线宽 |
| `lineCap` | 线帽 (`butt`/`round`/`square`) |
| `lineJoin` | 线连接 (`miter`/`round`/`bevel`) |
| `lineDashOffset` | 虚线偏移 |
| `shadowBlur` | 阴影模糊 |
| `shadowColor` | 阴影颜色 |
| `shadowOffsetX` | 阴影 X 偏移 |
| `shadowOffsetY` | 阴影 Y 偏移 |
| `globalAlpha` | 全局透明度 |
| `globalCompositeOperation` | 合成操作 (26种模式) |
| `font` | 字体 |
| `textAlign` | 文本对齐 (`left`/`center`/`right`/`start`/`end`) |
| `textBaseline` | 文本基线 (`top`/`hanging`/`middle`/`alphabetic`/`ideographic`/`bottom`) |

**支持的颜色格式**: `#rrggbb`, `#rgb`, `rgb(r,g,b)`, `rgba(r,g,b,a)`, 以及命名颜色 (`black`, `white`, `red`, `green`, `blue`, `yellow`, `transparent`)

**绘图方法**:

| 方法 | 说明 |
|---|---|
| `fillRect(x, y, w, h)` | 填充矩形 |
| `strokeRect(x, y, w, h)` | 描边矩形 |
| `clearRect(x, y, w, h)` | 清除矩形 |
| `beginPath()` | 开始路径 |
| `moveTo(x, y)` | 移动到 |
| `lineTo(x, y)` | 画线到 |
| `arc(x, y, r, start, end, ccw?)` | 圆弧 |
| `rect(x, y, w, h)` | 矩形路径 |
| `ellipse(x, y, rx, ry, rot, start, end, ccw?)` | 椭圆 |
| `arcTo(x1, y1, x2, y2, r)` | 圆弧连接 |
| `bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y)` | 三次贝塞尔 |
| `quadraticCurveTo(cpx, cpy, x, y)` | 二次贝塞尔 |
| `closePath()` | 闭合路径 |
| `roundRect(x, y, w, h, ...radii)` | 圆角矩形 |
| `clip([path][, fillRule])` | 裁剪 |
| `fill([path][, fillRule])` | 填充 |
| `stroke([path])` | 描边 |
| `measureText(text)` | 测量文本 (返回 `{ width }`) |
| `fillText(text, x, y, maxWidth?)` | 填充文本 |
| `strokeText(text, x, y, maxWidth?)` | 描边文本 |
| `save()` | 保存状态 |
| `restore()` | 恢复状态 |
| `translate(dx, dy)` | 平移 |
| `rotate(angle)` | 旋转 (弧度) |
| `scale(sx, sy)` | 缩放 |
| `transform(a, b, c, d, e, f)` | 矩阵变换 |
| `setTransform(...args)` | 设置变换矩阵 |
| `resetTransform()` | 重置变换 |
| `getTransform()` | 获取变换矩阵 (返回 DOMMatrixReadOnly) |
| `setLineDash(dashArray)` | 设置虚线 |
| `getLineDash()` | 获取虚线 |
| `isPointInPath(x, y [, fillRule])` | 点在路径内 |
| `isPointInStroke(x, y)` | 点在描边上 |
| `createImageData(w, h)` | 创建图像数据 |
| `getImageData(x, y, w, h)` | 获取图像数据 |
| `putImageData(imageData, x, y)` | 放置图像数据 |
| `createLinearGradient(x0, y0, x1, y1)` | 线性渐变 |
| `createRadialGradient(x0, y0, r0, x1, y1, r1)` | 径向渐变 |
| `createPattern(image, repetition)` | 图案 (当前使用内部 1x1 表面) |
| `drawImage(image, dx, dy [, dw, dh] [, sx, sy, sw, sh])` | 绘制图像 (仅接受 Canvas 实例) |
| `flush()` | 刷新 |

#### CanvasGradient

| 方法 | 说明 |
|---|---|
| `addColorStop(offset, color)` | 添加颜色停止点 |

#### CanvasPattern

| 方法 | 说明 |
|---|---|
| `setTransform(matrix)` | 设置变换矩阵 |

#### ImageData

| 属性 | 说明 |
|---|---|
| `width` | 宽度 |
| `height` | 高度 |
| `data` | 字节数组 (长度 = width × height × 4) |

构造: `new ImageData(width, height)`

#### Path2D

构造方式:
- `new Path2D()`
- `new Path2D(path)` — 克隆另一个 Path2D
- `new Path2D(svgPathString)` — 解析 SVG 路径数据

方法: `moveTo`, `lineTo`, `rect`, `roundRect`, `closePath`, `arc`, `arcTo`, `bezierCurveTo`, `quadraticCurveTo`, `ellipse`, `addPath(path, transform?)`, `toString()` (返回 SVG 路径数据)

---

### 7.2 wx 命名空间 API

```javascript
import wx from 'wx';
```

| API | 说明 |
|---|---|
| `wx.createCanvasContext(canvasId)` | 获取页面 Canvas 节点的 2D 上下文 |
| `wx.media.createCameraContext()` | 创建相机上下文 |

**相机 API**:

```javascript
const camera = wx.media.createCameraContext();
const photo = await camera.takePhoto({ quality: 'high' });
// photo.data.byteLength — 图片数据大小
```

---

### 7.3 Crypto API

```javascript
const uuid = crypto.randomUUID();
const hash = await crypto.subtle.digest('SHA-256', new TextEncoder().encode('hello AIUI'));
```

---

## 8. 设计规范

### 尺寸与布局

| 规范项 | 值 |
|---|---|
| 应用宽度 | **480px** (固定) |
| 应用高度 | **120px ~ 380px** (推荐) |
| 布局风格 | **Card Style** (推荐) |
| 默认背景色 | **黑色** |
| 默认边框宽度 | **2px** |
| 推荐圆角 | **12px** |

### 色彩体系

| 用途 | 颜色 | 透明度 |
|---|---|---|
| 主色/品牌色 | `#40FF5E` | 100% |
| 次要元素/悬停 | `rgba(64, 255, 94, 0.6)` | 60% |
| 背景高亮/禁用 | `rgba(64, 255, 94, 0.4)` | 40% |
| 默认文本色 | `#40FF5E` | 100% |

### 禁止事项

- **禁止在 UI 文案中使用 emoji**（除非开发者明确要求）
- **禁止使用大面积纯色块**（避免在可穿戴显示屏上造成视觉不适）

---

## 9. 依赖关系

### 运行时依赖图

```
AIUI 应用
├── AIUI Runtime (Ink 引擎)          ← 外部依赖，不在本仓库中
│   ├── WXML 渲染器
│   ├── WXSS 样式引擎
│   ├── JavaScript 运行时 (ESM)
│   ├── 内置组件库 (ink-builtin-components)
│   └── Canvas 2D 引擎
│
├── wx 模块                           ← 运行时提供的全局模块
│   ├── wx.createCanvasContext()
│   └── wx.media.createCameraContext()
│
└── crypto 全局对象                    ← 运行时提供
    ├── crypto.randomUUID()
    └── crypto.subtle.digest()
```

### npm 依赖

| 包名 | 版本 | 类型 | 说明 |
|---|---|---|---|
| `@yodaos-pkg/create-aiui-agent` | 2.1.2 | 发布包 | CLI 脚手架工具 |
| `jsui-dev-tools` | 1.0.0 | 根项目 | 仓库根项目配置 |

> 注意：生成的 AIUI Agent 项目模板的 `dependencies` 为空 `{}`，因为所有运行时 API 由 AIUI Runtime 提供。

### 开发工具依赖

| 工具 | 用途 |
|---|---|
| Node.js 20+ | 运行 CLI 和构建工具 |
| npm | 包管理器 |
| GitHub Actions | CI/CD 自动化 |

---

## 10. 项目运行方式

### 创建新项目

```bash
# 使用 CLI 脚手架创建项目
npm create @yodaos-pkg/aiui-agent my-agent

# 进入项目目录
cd my-agent

# 安装依赖
npm install

# 启动开发
npm start
```

### 安装 AI 开发技能

```bash
# 将 AIUI 开发技能安装到项目中
npx skills add https://github.com/jsar-project/AIUI/tree/main/skills/aiui-dev
```

### 运行示例应用

```bash
# 克隆仓库
git clone https://github.com/jsar-project/AIUI.git
cd AIUI/samples/simple

# 示例应用需要 AIUI Runtime 环境运行
# 在 AI 眼镜设备或模拟器中加载
```

### 开发工作流

```
1. 创建项目 → npm create @yodaos-pkg/aiui-agent my-agent
2. 编辑 Agent 声明 → 修改 AGENTS.md
3. 配置页面路由 → 修改 app.json
4. 开发页面 → 创建/编辑 .ink 文件
5. 添加静态资源 → 放入 assets/ 目录
6. 测试运行 → npm start
7. 迭代优化 → 修改代码 → 重新运行
```

### CLI 脚手架工作原理

```
用户执行: npx @yodaos-pkg/create-aiui-agent my-agent
    │
    ▼
index.js 解析命令行参数
    │
    ▼
验证目标目录不存在
    │
    ▼
递归复制 template/ → my-agent/
    │
    ▼
替换 {{PROJECT_NAME}} → my-agent
    │
    ▼
输出成功信息和后续步骤
```

### CI/CD 流程

```
每日 UTC 00:00 触发 (或手动触发)
    │
    ▼
Checkout 代码
    │
    ▼
Setup Node.js 20
    │
    ▼
cd packages/create-aiui-agent
    │
    ▼
npm publish --access public
    │
    ▼
发布到 npmjs.org
```

---

## 11. 关键类与函数说明

### CLI 模块

#### `copyDir(src, dest)`

| 属性 | 说明 |
|---|---|
| 位置 | `packages/create-aiui-agent/index.js` |
| 用途 | 递归复制模板目录到目标位置 |
| 参数 | `src` — 源目录路径, `dest` — 目标目录路径 |
| 行为 | 创建目标目录 → 遍历源目录 → 子目录递归复制 → 文件读取并替换 `{{PROJECT_NAME}}` → 写入目标 |

### 应用生命周期

#### `onLaunch()`

| 属性 | 说明 |
|---|---|
| 位置 | `app.js` / `.ink` `<script setup>` |
| 触发时机 | 应用首次启动时 |
| 用途 | 初始化全局数据、注册服务 |

#### `onShow()`

| 属性 | 说明 |
|---|---|
| 触发时机 | 应用从后台进入前台 |
| 用途 | 刷新数据、恢复状态 |

#### `onHide()`

| 属性 | 说明 |
|---|---|
| 触发时机 | 应用从前台进入后台 |
| 用途 | 暂停操作、保存状态 |

### 页面生命周期

#### `onLoad()`

| 属性 | 说明 |
|---|---|
| 触发时机 | 页面加载时 |
| 用途 | 初始化页面数据 |

### 数据更新

#### `this.setData(dataObject)`

| 属性 | 说明 |
|---|---|
| 位置 | 页面 `<script setup>` 中 |
| 用途 | 更新页面数据并触发视图刷新 |
| 参数 | `dataObject` — 要更新的键值对对象 |
| 示例 | `this.setData({ greeting: 'Hello!' })` |

### Canvas API 关键类

#### `Canvas`

| 属性 | 说明 |
|---|---|
| 构造 | `new Canvas(width, height)` |
| 方法 | `getContext('2d')` — 获取 2D 渲染上下文 |

#### `CanvasRenderingContext2D`

| 属性 | 说明 |
|---|---|
| 获取方式 | `canvas.getContext('2d')` 或 `wx.createCanvasContext(id)` |
| 注意 | 构造函数不可直接调用 |

#### `Path2D`

| 构造方式 | 说明 |
|---|---|
| `new Path2D()` | 空路径 |
| `new Path2D(path)` | 克隆路径 |
| `new Path2D(svgString)` | 从 SVG 路径数据解析 |

#### `ImageData`

| 属性 | 说明 |
|---|---|
| 构造 | `new ImageData(width, height)` |
| 属性 | `width`, `height`, `data` (Uint8ClampedArray) |

#### `CanvasGradient`

| 方法 | 说明 |
|---|---|
| `addColorStop(offset, color)` | 添加渐变色标 |

#### `CanvasPattern`

| 方法 | 说明 |
|---|---|
| `setTransform(matrix)` | 设置图案变换 |

---

> **文档来源**: 本 Code Wiki 基于对 [jsar-project/AIUI](https://github.com/jsar-project/AIUI) 仓库的完整分析生成，涵盖了项目架构、模块职责、组件参考、API 文档、设计规范和运行方式等关键信息。

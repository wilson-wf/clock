# 悬浮时钟应用设计文档

> HarmonyOS NEXT / ArkTS · 桌面悬浮时钟小挂件

## 目录

- [1. 项目概述](#1-项目概述)
- [2. 需求分析](#2-需求分析)
- [3. 技术选型](#3-技术选型)
- [4. 系统架构](#4-系统架构)
- [5. 模块设计](#5-模块设计)
- [6. 数据结构](#6-数据结构)
- [7. 关键实现方案](#7-关键实现方案)
- [8. 主题系统](#8-主题系统)
- [9. 交互设计](#9-交互设计)
- [10. 权限与安全](#10-权限与安全)
- [11. 性能考量](#11-性能考量)
- [12. 项目结构](#12-项目结构)
- [13. 构建与部署](#13-构建与部署)

---

## 1. 项目概述

### 1.1 项目背景

在鸿蒙 PC / 平板设备上，用户需要一个始终可见的桌面时间小挂件，方便在使用各类应用时随时查看时间，同时支持倒计时、秒表等实用功能。

### 1.2 项目目标

- 实现一个轻量级桌面悬浮时钟挂件
- 始终悬浮在所有应用窗口最前端
- 支持自由拖动改变位置
- 提供多种显示模式（时钟 / 倒计时 / 秒表）
- 支持多主题切换与用户配置持久化

### 1.3 目标平台

| 项目 | 规格 |
|------|------|
| 操作系统 | HarmonyOS 6.0+（HarmonyOS NEXT） |
| 设备类型 | PC / 平板 / 2in1 / 手机 |
| 开发语言 | ArkTS（TypeScript 超集） |
| UI 框架 | ArkUI（声明式开发范式） |
| 应用模型 | Stage 模型 |

---

## 2. 需求分析

### 2.1 功能需求

| 编号 | 功能模块 | 需求描述 | 优先级 |
|------|----------|----------|--------|
| F01 | 实时时钟 | 显示当前时间，精确到秒，每秒自动刷新 | P0 |
| F02 | 日期显示 | 显示当前日期与星期，可开关 | P1 |
| F03 | 悬浮窗显示 | 创建系统级悬浮窗，始终置顶于所有应用之上 | P0 |
| F04 | 自由拖动 | 用户可通过鼠标/触屏拖动改变悬浮窗位置 | P0 |
| F05 | 位置记忆 | 拖动结束后自动保存位置，下次启动恢复 | P1 |
| F06 | 主题切换 | 提供多种预设主题，用户可自由切换 | P1 |
| F07 | 倒计时模式 | 支持设置倒计时时长（1-60 分钟），最后 10 秒红色提醒 | P1 |
| F08 | 秒表模式 | 精确到 0.01 秒的秒表功能 | P1 |
| F09 | 模式切换 | 时钟 / 倒计时 / 秒表三种模式一键切换 | P1 |
| F10 | 设置菜单 | 长按悬浮窗弹出设置菜单 | P1 |
| F11 | 配置持久化 | 主题、模式、位置等用户偏好自动保存 | P1 |
| F12 | 主设置页 | 应用主界面提供可视化配置面板 | P2 |

### 2.2 非功能需求

| 类别 | 要求 |
|------|------|
| 性能 | 时钟每秒刷新，CPU 占用 < 1% |
| 流畅性 | 拖动帧率 ≥ 60fps，无卡顿 |
| 内存占用 | 悬浮窗运行时内存 < 50MB |
| 稳定性 | 7×24 小时运行无崩溃 |
| 适配性 | 支持手机、平板、PC 多设备形态 |
| 可扩展性 | 主题、模式可灵活扩展 |

### 2.3 约束条件

- 必须使用 HarmonyOS 官方 API（`@kit.*` 命名空间）
- 悬浮窗类型必须使用系统级 `TYPE_FLOAT`
- 需要用户授权悬浮窗权限

---

## 3. 技术选型

### 3.1 核心技术栈

| 技术领域 | 选型 | 选型理由 |
|----------|------|----------|
| 开发语言 | ArkTS | HarmonyOS 官方推荐，基于 TypeScript 扩展 |
| UI 框架 | ArkUI（声明式） | 现代化声明式 UI，高性能渲染 |
| 应用模型 | Stage 模型 | HarmonyOS NEXT 标准应用模型 |
| 悬浮窗 | `@kit.ArkUI window` | 系统窗口管理 API，支持 `TYPE_FLOAT` |
| 数据持久化 | `@kit.ArkData preferences` | 轻量级 KV 存储，适合保存用户偏好 |
| 日志 | `@kit.PerformanceAnalysisKit hilog` | 鸿蒙系统日志框架 |
| 状态管理 | `@State / @Prop / @Link` | ArkUI 内置响应式状态管理 |

### 3.2 关键 API

| API 模块 | 用途 |
|----------|------|
| `window.createWindow()` | 创建悬浮窗口 |
| `Window.moveWindowTo()` | 移动窗口位置 |
| `Window.setWindowLayout()` | 设置窗口尺寸 |
| `Window.showWindow() / hideWindow()` | 显示/隐藏窗口 |
| `Window.setWindowBackgroundColor()` | 设置透明背景 |
| `PanGesture` | 拖拽手势识别 |
| `LongPressGesture` | 长按手势 |
| `TapGesture` | 点击手势 |
| `preferences.getPreferences()` | 获取持久化存储实例 |
| `setInterval / clearInterval` | 定时器刷新时间 |

---

## 4. 系统架构

### 4.1 整体架构图

```
┌──────────────────────────────────────────────────────────────┐
│                      FloatingClock App                        │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                  应用层 (Presentation)                 │  │
│  │                                                        │  │
│  │  ┌─────────────┐    ┌─────────────────────────────┐   │  │
│  │  │ Index 页面   │    │  FloatingClock 悬浮窗页面    │   │  │
│  │  │  (设置面板)  │    │                             │   │  │
│  │  │             │    │  ┌───────────────────────┐  │   │  │
│  │  │ - 主题选择   │    │  │   ClockWidget         │  │   │  │
│  │  │ - 模式选择   │    │  │   (实时时钟组件)       │  │   │  │
│  │  │ - 倒计时配置 │    │  ├───────────────────────┤  │   │  │
│  │  │ - 显示/隐藏  │    │  │   CountdownWidget     │  │   │  │
│  │  └─────────────┘    │  │   (倒计时组件)          │  │   │  │
│  │                      │  ├───────────────────────┤  │   │  │
│  │                      │  │   StopwatchWidget     │  │   │  │
│  │                      │  │   (秒表组件)            │  │   │  │
│  │                      │  └───────────────────────┘  │   │  │
│  │                      │                             │   │  │
│  │                      │  - 拖拽手势处理             │   │  │
│  │                      │  - 长按菜单                 │   │  │
│  │                      └─────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────┘  │
│                             │                                 │
│  ┌──────────────────────────▼──────────────────────────────┐ │
│  │                   业务层 (Business Logic)               │ │
│  │                                                         │ │
│  │  ┌─────────────────────┐  ┌─────────────────────────┐  │ │
│  │  │ FloatingWindowMgr   │  │  ThemeManager           │  │ │
│  │  │ (悬浮窗管理器)       │  │  (主题管理器)            │  │ │
│  │  │ - 创建/销毁窗口      │  │  - 主题列表             │  │ │
│  │  │ - 移动/调整大小      │  │  - 主题查找             │  │ │
│  │  │ - 显示/隐藏          │  └─────────────────────────┘  │ │
│  │  └─────────────────────┘                               │ │
│  └─────────────────────────────────────────────────────────┘ │
│                             │                                 │
│  ┌──────────────────────────▼──────────────────────────────┐ │
│  │                    数据层 (Data)                        │ │
│  │                                                         │ │
│  │  ┌─────────────────────┐  ┌─────────────────────────┐  │ │
│  │  │ PreferencesUtil     │  │  TimeFormatter          │  │ │
│  │  │ (配置持久化工具)     │  │  (时间格式化工具)        │  │ │
│  │  │ - 主题/模式/位置    │  │  - 时钟格式化           │  │ │
│  │  │ - 倒计时时长        │  │  - 倒计时格式化         │  │ │
│  │  └─────────────────────┘  │  - 秒表格式化           │  │ │
│  │                             └─────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### 4.2 分层设计原则

- **单一职责**：每个模块只负责一个明确的功能领域
- **依赖倒置**：上层依赖下层抽象，下层不感知上层
- **组件化**：UI 组件独立封装，可复用、可测试
- **状态集中**：核心状态由悬浮窗页面统一管理，组件通过 `@Link/@Prop` 同步

---

## 5. 模块设计

### 5.1 模块清单

| 模块 | 所在文件 | 职责 |
|------|----------|------|
| EntryAbility | `entryability/EntryAbility.ets` | 应用入口，初始化管理器和上下文 |
| Index Page | `pages/Index.ets` | 主设置页面，主题/模式/倒计时配置 |
| FloatingClock Page | `pages/FloatingClock.ets` | 悬浮窗 UI，含拖拽、菜单、模式切换 |
| ClockWidget | `components/ClockWidget.ets` | 实时时钟组件 |
| CountdownWidget | `components/CountdownWidget.ets` | 倒计时组件 |
| StopwatchWidget | `components/StopwatchWidget.ets` | 秒表组件 |
| ThemeManager | `model/Theme.ets` | 主题定义与管理 |
| FloatingWindowManager | `utils/FloatingWindowManager.ets` | 悬浮窗创建、移动、销毁单例 |
| PreferencesUtil | `utils/PreferencesUtil.ets` | 用户偏好持久化工具 |
| TimeFormatter | `utils/TimeFormatter.ets` | 时间字符串格式化工具 |

### 5.2 核心模块详细设计

#### 5.2.1 FloatingWindowManager（悬浮窗管理器）

**设计模式**：单例模式（Singleton）

```
FloatingWindowManager
├── 字段
│   ├── instance: FloatingWindowManager  (静态单例)
│   ├── context: Context                 (应用上下文)
│   ├── floatingWindow: Window           (悬浮窗实例)
│   ├── currentX / currentY: number      (当前坐标)
│   └── isShown: boolean                 (是否显示)
├── 方法
│   ├── getInstance(): FloatingWindowManager
│   ├── setContext(ctx)
│   ├── createFloatingWindow(w, h, x, y): Promise<boolean>
│   ├── moveWindowTo(x, y): Promise<void>
│   ├── setWindowLayout(w, h): Promise<void>
│   ├── showFloatingWindow(): Promise<void>
│   ├── hideFloatingWindow(): Promise<void>
│   ├── destroyFloatingWindow(): void
│   └── getPosition(): {x, y}
```

**关键流程 — 创建悬浮窗**：

```
调用 createFloatingWindow()
    │
    ▼
检查 context 是否为空 ──空──▶ 返回 false
    │
    ▼
检查 window 是否已存在 ──是──▶ 直接 showWindow()
    │
    ▼
window.createWindow(TYPE_FLOAT)
    │
    ▼
setWindowLayout(width, height)   ← 设置小挂件尺寸
    │
    ▼
moveWindowTo(x, y)               ← 设置初始位置
    │
    ▼
setWindowBackgroundColor(透明)   ← 背景透明，只显示内容
    │
    ▼
setUIContent('pages/FloatingClock')  ← 加载悬浮窗页面
    │
    ▼
setWindowFocusable(false)        ← 不抢焦点（可选）
    │
    ▼
showWindow()
    │
    ▼
返回 true
```

#### 5.2.2 PreferencesUtil（配置持久化）

**存储键值列表**：

| Key | 类型 | 默认值 | 说明 |
|-----|------|--------|------|
| `theme_name` | string | `"dark"` | 当前主题名称 |
| `display_mode` | string | `"clock"` | 显示模式：clock / countdown / stopwatch |
| `countdown_seconds` | number | `300` | 倒计时总秒数 |
| `show_date` | boolean | `true` | 是否显示日期 |
| `window_x` | number | `200` | 悬浮窗 X 坐标 |
| `window_y` | number | `200` | 悬浮窗 Y 坐标 |

#### 5.2.3 FloatingClock 页面（悬浮窗 UI 容器）

**状态变量**：

| 状态 | 类型 | 说明 |
|------|------|------|
| `themeName` | string | 当前主题名 |
| `mode` | string | 当前显示模式 |
| `showDate` | boolean | 是否显示日期 |
| `showMenu` | boolean | 设置菜单展开状态 |
| `countdownIsRunning` | boolean | 倒计时运行状态 |
| `countdownRemaining` | number | 倒计时剩余秒数 |
| `countdownTotal` | number | 倒计时总秒数 |
| `stopwatchIsRunning` | boolean | 秒表运行状态 |
| `stopwatchElapsed` | number | 秒表已过毫秒数 |

**手势组合**：

| 手势 | 触发条件 | 行为 |
|------|----------|------|
| TapGesture (1 指单击) | 单击悬浮窗 | 时钟模式：打开菜单；倒计时/秒表模式：启停 |
| LongPressGesture (500ms) | 长按悬浮窗 | 打开/收起设置菜单 |
| PanGesture (距离 5vp) | 按住拖动 | 移动悬浮窗位置 |

---

## 6. 数据结构

### 6.1 主题数据结构

```typescript
interface ThemeStyle {
  name: string;           // 主题唯一标识
  label: string;          // 显示名称
  bgColor: string;        // 背景色（支持 rgba）
  textColor: string;      // 主文字色
  subTextColor: string;   // 次要文字色
  borderColor: string;    // 边框色
  shadowColor: string;    // 阴影色
}
```

### 6.2 悬浮窗配置

```typescript
interface FloatingConfig {
  width: number;          // 窗口宽度 (vp)
  height: number;         // 窗口高度 (vp)
  x: number;              // X 坐标
  y: number;              // Y 坐标
  theme: string;          // 主题名
  mode: DisplayMode;      // 显示模式
  showDate: boolean;      // 是否显示日期
}

type DisplayMode = 'clock' | 'countdown' | 'stopwatch';
```

---

## 7. 关键实现方案

### 7.1 悬浮窗置顶方案

**使用窗口类型**：`window.WindowType.TYPE_FLOAT`

`TYPE_FLOAT` 是鸿蒙系统提供的系统级悬浮窗口类型，具有以下特性：
- 自动显示在所有应用窗口之上（最高 z-order）
- 不影响下方窗口的交互
- 支持透明背景
- 需要 `ohos.permission.SYSTEM_FLOAT_WINDOW` 权限

**核心代码示意**：

```typescript
this.floatingWindow = await window.createWindow(
  this.context,
  'floating_clock_widget',
  window.WindowType.TYPE_FLOAT
);
await this.floatingWindow.setWindowBackgroundColor('#00000000'); // 透明背景
await this.floatingWindow.setUIContent('pages/FloatingClock');
await this.floatingWindow.showWindow();
```

### 7.2 拖拽实现方案

**技术方案**：`PanGesture` + `moveWindowTo()`

```
用户按下 ──▶ 记录起始坐标 (dragStartX, dragStartY)
                记录窗口起始位置 (windowStartX, windowStartY)
     │
     ▼
拖动中 ──▶ 计算偏移量 dx = offsetX - dragStartX
              计算偏移量 dy = offsetY - dragStartY
              新位置 = (windowStartX + dx, windowStartY + dy)
              调用 moveWindowTo(newX, newY)
     │
     ▼
松手 ──▶ 保存最终位置到 Preferences
```

**防抖处理**：设置 `distance: 5` 的阈值，避免轻微触碰触发拖拽。

### 7.3 实时时钟刷新方案

**技术方案**：`setInterval` + `Date` 对象

```
aboutToAppear() ──▶ setInterval(updateTime, 1000)
updateTime()     ──▶ new Date() → 格式化 → 更新 @State
aboutToDisappear() ──▶ clearInterval(timerId)
```

**性能优化点**：
- 使用 `@State` 仅触发 UI 局部刷新
- 每秒仅更新 1 次，CPU 占用极低
- 页面销毁时清理定时器，避免内存泄漏

### 7.4 倒计时实现方案

**状态机**：

```
    ┌─────────────┐
    │   初始态     │  remaining = total, running = false
    └──────┬──────┘
           │ 单击
           ▼
    ┌─────────────┐
    │   运行中     │  setInterval 每秒 -1
    └──────┬──────┘
           │ 单击
           ▼
    ┌─────────────┐
    │   暂停态     │  remaining 保持当前值
    └──────┬──────┘
           │ 单击
           ▼
    回到运行中 ...
           │ remaining == 0
           ▼
    ┌─────────────┐
    │   完成态     │  红色闪烁 + 自动停止
    └─────────────┘
```

### 7.5 模式切换方案

通过 `cycleMode()` 方法循环切换三种模式：

```
clock → countdown → stopwatch → clock ...
```

切换时重置对应模式的运行状态，避免状态残留。

---

## 8. 主题系统

### 8.1 预设主题

| 主题名 | 说明 | 主色调 |
|--------|------|--------|
| `dark` | 经典深色 | 黑底白字 |
| `light` | 清爽浅色 | 白底深灰字 |
| `ocean` | 海洋蓝 | 深蓝背景 + 浅蓝文字 |
| `sunset` | 日落橙 | 深棕红背景 + 暖橙文字 |
| `forest` | 森林绿 | 深绿背景 + 浅绿文字 |
| `mono` | 极简黑白 | 深灰背景 + 白色文字 |

### 8.2 主题切换机制

1. `ThemeManager.THEMES` 存储所有预设主题
2. `PreferencesUtil.setTheme()` 持久化用户选择
3. 悬浮窗页面 `@State themeName` 响应式驱动 UI 重绘
4. 所有颜色从 `getTheme()` 方法动态获取

### 8.3 扩展方式

新增主题只需在 `ThemeManager.THEMES` 数组中添加一项：

```typescript
{
  name: 'neon',
  label: '霓虹紫',
  bgColor: 'rgba(40, 10, 60, 0.85)',
  textColor: '#F3E5F5',
  subTextColor: 'rgba(243, 229, 245, 0.7)',
  borderColor: 'rgba(200, 100, 255, 0.3)',
  shadowColor: 'rgba(40, 10, 60, 0.4)'
}
```

---

## 9. 交互设计

### 9.1 悬浮窗交互

| 操作 | 时钟模式 | 倒计时模式 | 秒表模式 |
|------|----------|------------|----------|
| 单击 | 打开设置菜单 | 启动/暂停 | 启动/暂停 |
| 长按 500ms | 打开设置菜单 | 打开设置菜单 | 打开设置菜单 |
| 拖动 | 移动位置 | 移动位置 | 移动位置 |

### 9.2 设置菜单选项

- **切换主题**：循环切换 6 种预设主题
- **切换模式**：循环切换时钟/倒计时/秒表
- **显示/隐藏日期**：切换日期显示开关
- **重置倒计时/秒表**：（对应模式下出现）
- **关闭悬浮窗**：隐藏悬浮窗口
- **收起菜单**：关闭设置面板

### 9.3 主设置页交互

- 可视化主题预览与选择（2 行 3 列网格）
- 模式切换按钮组
- 倒计时时长滑块（1-60 分钟）
- 显示日期开关
- 显示/隐藏悬浮窗大按钮

---

## 10. 权限与安全

### 10.1 所需权限

| 权限名 | 级别 | 用途 | 申请时机 |
|--------|------|------|----------|
| `ohos.permission.SYSTEM_FLOAT_WINDOW` | 系统级 | 创建系统悬浮窗 | 首次启动时动态申请 |
| `ohos.permission.KEEP_BACKGROUND_RUNNING` | 正常 | 后台持续运行 | 安装时静态声明 |

### 10.2 权限声明位置

文件：`entry/src/main/module.json5`

```json5
{
  "requestPermissions": [
    {
      "name": "ohos.permission.SYSTEM_FLOAT_WINDOW",
      "reason": "$string:permission_float_reason",
      "usedScene": {
        "abilities": ["EntryAbility"],
        "when": "inuse"
      }
    }
  ]
}
```

### 10.3 安全设计

- 不收集任何用户数据
- 所有配置仅存储在本地 `preferences` 中
- 不访问网络、不读写外部存储
- 不请求通讯录、位置等敏感权限

---

## 11. 性能考量

### 11.1 内存优化

- 悬浮窗使用独立 Window，不常驻主 Activity
- 组件化设计，按需加载
- 定时器在页面销毁时及时清理

### 11.2 渲染性能

- 使用 ArkUI 声明式 UI，底层自动 diff 更新
- 时钟每秒仅刷新 1 次文本
- 悬浮窗尺寸小（240×120 vp），渲染开销低
- 拖拽使用系统级 `moveWindowTo`，无重绘开销

### 11.3 电量优化

- 时钟刷新频率 1Hz，非常低
- 倒计时/秒表仅在运行时才启动定时器
- 应用退到后台时悬浮窗不受影响，但主页面释放资源

---

## 12. 项目结构

```
workspace/
├── AppScope/
│   └── app.json5                    # 应用全局配置
├── entry/
│   ├── build-profile.json5          # 模块构建配置
│   ├── hvigorfile.ts                # Hvigor 构建脚本
│   └── src/main/
│       ├── module.json5             # 模块配置 + 权限声明
│       ├── resources/
│       │   └── base/
│       │       ├── element/
│       │       │   ├── string.json  # 多语言字符串
│       │       │   ├── color.json   # 颜色资源
│       │       │   └── boolean.json # 布尔资源
│       │       ├── media/           # 应用图标
│       │       │   ├── app_icon.png
│       │       │   ├── app_icon_circle.png
│       │       │   ├── app_icon_foreground.png
│       │       │   └── app_icon_background.png
│       │       └── profile/
│       │           └── main_pages.json  # 页面注册
│       └── ets/
│           ├── entryability/
│           │   └── EntryAbility.ets     # 应用入口
│           ├── pages/
│           │   ├── Index.ets            # 主设置页
│           │   └── FloatingClock.ets    # 悬浮窗页面
│           ├── components/
│           │   ├── ClockWidget.ets      # 时钟组件
│           │   ├── CountdownWidget.ets  # 倒计时组件
│           │   └── StopwatchWidget.ets  # 秒表组件
│           ├── model/
│           │   └── Theme.ets            # 主题数据模型
│           └── utils/
│               ├── FloatingWindowManager.ets  # 悬浮窗管理器
│               ├── PreferencesUtil.ets         # 配置持久化
│               └── TimeFormatter.ets           # 时间格式化
├── hvigor/
│   └── hvigor-wrapper.js
├── hvigorfile.ts
├── build-profile.json5
├── package.json
├── .gitignore
├── README.md
└── DESIGN.md                          # 本文档
```

---

## 13. 构建与部署

### 13.1 构建环境要求

| 工具 | 版本要求 |
|------|----------|
| DevEco Studio | 5.0+（支持 HarmonyOS NEXT） |
| HarmonyOS SDK | API 12+（HarmonyOS 6.0+） |
| Node.js | 18+ |

### 13.2 构建命令

```bash
# 清理
./hvigorw clean

# 构建 Debug HAP
./hvigorw assembleHap --mode debug

# 构建 Release HAP
./hvigorw assembleHap --mode release

# 构建 APP 包（含多个 HAP）
./hvigorw assembleApp
```

### 13.3 产物路径

```
# HAP 安装包
entry/build/default/outputs/default/entry-default-signed.hap

# APP 包
build/default/outputs/default/app-default-signed.app
```

### 13.4 安装到设备

```bash
# 使用 hdc 安装
hdc install entry-default-signed.hap

# 或直接在 DevEco Studio 中点击 Run 按钮
```

---

## 附录：后续可扩展方向

- [ ] 番茄钟模式（25 分钟工作 + 5 分钟休息）
- [ ] 自定义主题颜色（颜色选择器）
- [ ] 闹钟提醒功能
- [ ] 世界时钟 / 多时区显示
- [ ] 桌面小组件（ArkTS Widget）
- [ ] 数据同步（云端备份配置）
- [ ] 更多主题与字体
- [ ] 透明度调节

---

*文档版本：v1.0*
*最后更新：2026-06-19*

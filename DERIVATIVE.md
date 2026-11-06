# 本仓库说明：JJYB AI 智剪的个人改造版

本仓库是 [jianjieyiban/JJYB_AI_VideoAutoCut](https://github.com/jianjieyiban/JJYB_AI_VideoAutoCut)
的**个人学习用改造版**，不是上游官方版本，也不是我的原创项目。

## 一、许可与边界（先读）

上游采用 **JJYB_AI_VideoAutoCut Personal Use License v1.0**（见 [LICENSE](LICENSE)），
是「源码公开但非开源」的个人使用许可，关键限制：

- 不得用于任何直接或间接商业用途（含企业内部生产、代运营、SaaS、付费服务）。
- 不得删除或隐藏版权、作者、来源与许可声明。
- 不得使用与上游相同或足以造成混淆的名称发布衍生产品。
- 本仓库**不再以其他许可重新授权**，衍生部分一并适用上游许可。

因此本仓库：**私有**、仅个人非商业使用、保留上游 LICENSE 与署名
（`config/config.yaml` 中 `app.attribution` 保持「基于 JJYB_AI_VideoAutoCut 改造」）。

## 二、我改了什么（27 个文件 / +348 −66 行）

### 1. 分镜规划：短镜头不再导致整条规划失败

`backend/engine/storyboard_planner.py`

- 原逻辑：某镜可用时长 < 该段配音时长时直接跳过，如果所有候选都被跳过，
  整个规划抛 `not enough source material`，任务在这里就死了。
- 改造：把「可用但不够长」的短镜头**保留为候选**（`available >= MIN_WINDOW_SECONDS`），
  由渲染阶段用慢放/末帧定格把画面补到配音长度；并新增 `allow_reuse` 开关，
  素材池不够时退化为**循环复用画面窗口**，保证仍能出片而不是直接报错。
- 同时把「素材不足」的报错补上每段 `idx / duration` 明细，便于定位是哪段素材太短。

### 2. 音画同步：短镜头自动定格 + 末帧克隆兜底

`backend/engine/puppet_sync_engine.py`

- 当 `目标时长 > 源画面时长` 时，策略自动从 `direct / cut_highlight` 切到 `freeze`
  （原画面 + 末帧定格），而不是截出一段比配音短的画面。
- 增加最后一道兼容兜底：部分编码器/关键帧边界会让慢放或定格滤镜输出少几帧，
  此时用 `tpad=stop_mode=clone` 克隆末帧补齐到目标时长，
  避免**整条成片因为一个边界片段而中止**。正常路径仍走严格时长校验，兜底只在异常时触发。

### 3. 解说文案：无视觉模型时强制「严格视觉锚定」

`backend/services/commentary_service_enhanced.py`

- 本地分析只能给出亮度、色彩等弱标签。此时如果再套「悬念/反转」模板，
  会凭空生成与画面无关的剧情。
- 改造：检测到没有可用的云端视觉模型（或没有有效的增强描述）时，
  自动开启 `strict_visual_grounding`，禁用剧情脑补，只允许基于画面可见证据的客观表达。

### 4. 原创解说：多视频批量上传与自动合并

`backend/api/upload_routes.py`（新增 `POST /api/upload/merge-videos`）+ `frontend/templates/commentary.html`

- 支持一次上传多段素材，按顺序合并为一个主素材再进入解说流程；
  合并前校验路径必须落在项目目录内，避免任意路径读取。

### 5. 品牌配置驱动

`frontend/app.py`（新增 `APP_IDENTITY` + `context_processor`）、`config/config.yaml`、21 个模板

- 应用名、副标题、版本、上游署名统一从 `config/config.yaml` 的 `app` 区块读取，
  模板通过 `app_identity` 上下文变量渲染，换名不再需要满仓库改字符串。
- `attribution` 字段刻意保留上游来源说明，不随品牌化移除。

### 6. 浏览器模式：绕过 WebView2 的 POST/fetch 拦截

`frontend/app.py`

- 部分 Windows 环境的 WebView2 会拦截页面内的 POST/fetch，
  导致「点了没反应」。新增浏览器模式：用系统浏览器访问同一个 Flask 服务，绕开桌面容器限制。

### 7. 火山 Seed Audio V3 配音通道

`backend/api/settings_api.py`、`frontend/templates/settings.html`

- 新增 v3 协议（`X-Api-Key` 头，不再走旧的 app/token/voice_type 三段式），
  支持模型选择与「连接测试」，密钥打码回填时不会被明文覆盖。

## 三、不属于我的部分

- 上游的 UI 设计、模板体系、任务调度、剪辑/配音/声音复刻/剪映草稿导出等能力均为上游作者实现。
- 第三方组件（FFmpeg、Flask、PyWebView、OpenCV、PyTorch、faster-whisper 等）归各自作者所有。
- 本仓库不含模型权重、用户素材、数据库与成片。

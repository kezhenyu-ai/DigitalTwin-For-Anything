# DigitalTwin For Anything

## 滨河铸铁 · 铸造工厂污染排放数字孪生

基于 **Three.js + Vite** 的 Web 端铸铁件生产厂数字孪生指挥中心。项目以全流程铸铁产线为场景，整合排放监测（CEMS）、设备运行、运行日志、能源分表与实时视频监控，并在浏览器端实现接近 UE5 展示质感的工业可视化。

> 当前数据、CEMS 读数和视频画面为本地演示源（demo telemetry / simulated optics），用于完整呈现系统交互与数据链路。接入真实数据的方法见“接入真实系统”。

## 在线演示

GitHub Pages：

**https://kezhenyu-ai.github.io/DigitalTwin-For-Anything/**

演示账号：

```text
admin / Binhe@2026
```

> GitHub Pages 是纯静态托管，不能运行 Vite/Node 中间件。在线版使用浏览器本地校验登录，AI 使用基于当前看板数据的本地规则分析，未调用大模型。完整登录会话与 DeepSeek AI 请在本地运行 `npm run dev`。

---

## 1. 功能一览

### 厂区数字孪生
- 全流程产线建模：原料堆场 → 中频熔炼 → 砂处理 → 造型 → 浇注 → 落砂/抛丸清理 → 涂装/RTO → 成品库。
- 4 根 CEMS 排放烟囱、无组织排放监测点、除尘器、冷却塔、空压站、桥式起重机、控制室。
- 动态元素：熔融金属光效、炉口火星、烟羽、冷却塔蒸汽、浇注小车、输送造型线、桥吊、风机、流动能量路径、行走人员。
- 数字孪生演绎：PBR 金属/混凝土材质、程序化纹理、IBL 环境反射、ACES Filmic 色调映射、UnrealBloom 泛光、距离雾、浮尘、体积光、扫描网格。

### 实时视频监控
- 8 路视频通道：4 个有组织排放口 + 浇注区 + 原料堆场 + 造型线 + 成品库。
- 单个 WebGL 画布通过多视口渲染 4 路固定摄像机，10 fps 刷新，避免创建 8 个额外 WebGL 上下文。
- 四分屏 / 单画面、通道切换、分页、实时时间戳、REC 标识、CEMS 联动值、码流与存储信息。
- 每个画面由数字孪生场景实时渲染，后续可无缝替换为现场 RTSP / GB28181 / WebRTC 流。

### 生产设备状态与运行日志
- 14 台关键设备运行总览：运行 / 待机 / 预警 / 维护 / 离线。
- 设备详情抽屉：实时功率、负载率、温度、振动、今日耗电、运行时长、保养计划、设备级事件。
- 点击设备可定位并聚焦相机；支持下发待机 / 恢复运行、创建维护工单。
- 运行日志持续追加：全部 / 信息 / 预警 / 报警 / 操作筛选、全文搜索、CSV 导出、localStorage 留存最近 220 条。
- 报警自动记录：排放浓度越过 82% 预警阈值或超过限值时，自动生成环境报警与日志。

### 能源分表计量
- 6 个工段分表：熔炼、造型浇注、清理抛丸、涂装烘干、公用动力、环保治理。
- 电 / 天然气 / 水 / 压缩空气四类介质切换。
- 24 小时负荷曲线（今日实测、昨日同期）、峰谷值、负荷率。
- 当前功率、今日累计、占比、吨铸件电耗、电费、碳排放、绿电占比。
- 底部常驻能源条 + 实时 sparkline。

### AI 运营助手
- 右上角 `AI` 按钮或快捷键 `Alt + A` 打开 Chatbox。
- 基于当前看板实时数据回答：排放风险排序、设备预警解读、能耗分析、值班交接摘要等。
- 后端通过 `server/ai.mjs` 代理调用 DeepSeek 模型（默认 `deepseek-flash`），API Key 不会进入浏览器。
- 对话打开时每 12 秒同步一次压缩遥测快照；每次提问前会强制刷新，回答完成后显示响应耗时。
- 支持快捷问题、清空对话、输入框自动增高、Esc 关闭；聊天记录保留在当前会话内。

### 看板收放
- 顶部 `看板` 按钮可收起左右信息栏与底部能源条，露出完整三维场景；再次点击展开。
- 收起后右侧中部保留“展开看板”浮标，点击即可恢复。
- 看板状态使用 CSS 过渡动画，不重建场景或 WebGL 上下文。

### 安全登录
- 启动时先进入全屏身份认证界面，认证通过后才初始化 Three.js 场景。
- 支持安全会话恢复（HttpOnly Cookie，默认 8 小时）、显示/隐藏口令、保持会话、失败抖动提示。
- 顶栏左侧用户头像可打开账户菜单并退出登录。
- 演示账号：`admin` / `Binhe@2026`。
- 登录服务默认账号可通过 `AUTH_USER`、`AUTH_PASSWORD`、`AUTH_NAME`、`AUTH_ROLE` 覆盖。
- AI 的遥测与对话接口要求有效登录会话，未登录时返回 `401`。

> 当前认证为本地演示实现，会话保存在 Vite 服务进程内存中，服务重启后需要重新登录；生产环境应替换为 SSO / 数据库账号体系，并启用 HTTPS 与 Secure Cookie。

---

## 2. 启动

```bash
npm install
npm run dev
```

访问 `http://localhost:5173/`。首次进入会显示安全认证页，演示账号：

```text
操作员编号：admin
访问口令：Binhe@2026
```

登录成功后才初始化数字孪生场景。生产构建：

```bash
npm run build
npm run preview
```

静态演示构建（当前 GitHub Pages 使用）：

```bash
VITE_STATIC_DEMO=true VITE_BASE=/DigitalTwin-For-Anything/ npm run build -- --outDir dist-pages
```

Windows PowerShell：

```powershell
$env:VITE_STATIC_DEMO='true'
$env:VITE_BASE='/DigitalTwin-For-Anything/'
npm run build -- --outDir dist-pages
```

也可以直接双击根目录的 `start-gpu.bat`：脚本会检查/启动本地服务，并用带 Vulkan / 高性能 GPU 参数的独立浏览器配置打开页面。

## 3. 性能与 GPU 加速（RTX 4050 卡顿排查）

### 实测结论

当前默认使用**高精度模式**，不做自动降级。同一份构建在测试机上：

| 浏览器图形后端 | 实测 FPS | 说明 |
| --- | ---: | --- |
| ANGLE / Vulkan / Intel Arc（硬件） | **约 51 FPS** | 1600×900 CSS、DPR 2、高精度 1.6× 超采样实际渲染 2560×1440，443 Draw Calls，11.3 万三角面 |
| SwiftShader / WARP（CPU 软件渲染） | 1–3 FPS | 画面能显示，但交互明显卡顿 |

因此模型本身不是瓶颈。若浏览器回退到 **SwiftShader** 或 **D3D11 WARP**，即使机器装有 RTX 4050 也不会参与渲染。页面内置 GPU 检测：出现软件渲染时，场景右下角显示 `SOFTWARE`，顶部出现提示条和修复入口，但**仍保持高精度渲染**。

### 先在页面内确认

1. 点击场景右下 `SCENE` 工具组 → 图层按钮，打开 **RENDER PROFILE**。
2. 查看 **GPU 渲染器**：
   - 出现 `NVIDIA GeForce RTX 4050`：硬件加速正常。
   - 出现 `Intel Arc`：硬件加速正常，高精度模式实测约 51 FPS。
   - 出现 `SwiftShader` / `WARP` / `llvmpipe` / `Microsoft Basic Render`：正在使用 CPU 渲染。
3. 软件渲染下不会自动降低精度，只提示修复；需要临时降低负载时可手动选择“均衡 / 轻量”。

### 修复步骤

1. **开启浏览器硬件加速**：Edge → `edge://settings/system`；Chrome → `chrome://settings/system`。启用“使用图形加速 / 硬件加速”，完全退出浏览器后重启。
2. **Windows 指定高性能显卡**：设置 → 系统 → 显示 → 图形 → 添加 `msedge.exe` / `chrome.exe` → 选项 → 高性能 → 保存。
3. **NVIDIA 控制面板**：管理 3D 设置 → 程序设置 → 添加浏览器 → 首选图形处理器选择 `NVIDIA GeForce RTX 4050 Laptop GPU`。
4. **避免远程桌面 / 节能模式**：ToDesk、远程桌面和部分省电模式会强制浏览器走软件渲染，请在本机桌面直接打开，并接入电源。
5. **使用 GPU 启动脚本**：双击 `start-gpu.bat`，或按浏览器使用 `start-gpu-edge.bat` / `start-gpu-chrome.bat`。脚本使用独立浏览器配置和参数：
   `--use-angle=vulkan --enable-gpu --ignore-gpu-blocklist --force_high_performance_gpu --disable-gpu-sandbox`

### 本机已应用设置

- Windows 图形首选项已将 `msedge.exe`、`chrome.exe`、`DeepSeek Harness.exe`、`msedgewebview2.exe` 写入 `HKCU\Software\Microsoft\DirectX\UserGpuPreferences`，值均为 `GpuPreference=2;`（高性能）。
- Edge / Chrome 的硬件加速开关在当前用户配置中均为开启。
- 已给任务栏 / 开始菜单中的 Chrome、Edge 标准快捷方式追加 Vulkan 启动参数，原快捷方式备份在 `config-backup/`。
- 桌面上已创建 `BinheTwinGPU.lnk` GPU 启动快捷方式（默认浏览器；Chrome 用户可运行 `start-gpu-chrome.bat`）。
- 当前会话中正在运行的 Chrome / Edge GPU 进程仍使用 `d3d11-warp-webgl`；必须完全退出浏览器后，通过 GPU 快捷方式重新启动，设置才会生效。

> 当前测试机上 `--use-angle=vulkan` 枚举到的是 Intel Arc Pro Graphics；NVIDIA RTX 4050 未被 Vulkan 枚举（`nvidia-smi` 返回 GPU access blocked by OS）。如果需要使用 RTX 4050，请按下面的“T14p 特别说明”处理后重启，再检查。

### T14p Gen 2（21KU0000CD）特别说明

- 该机型**没有 MUX / 独显直连开关**，也不支持纯核显模式，BIOS 和 Vantage 中不存在“独显直连”选项。BIOS 若有 `Config → Display → Graphics Device`，保持默认的 **Hybrid Graphics** 即可，不要为了追求直连改成 Discrete Graphics。
- 当前 BIOS 为 `R2DET38W (1.23, 2025-02-25)`。请优先用“联想电脑管家 → 驱动管理”按机型检测 BIOS/驱动更新；[联想官方 BIOS 页面](https://think.lenovo.com.cn/support/driver/driverdetail.aspx?DEditid=162303&docTypeID=DOC_TYPE_DRIVER)当前列出 1.28，但下载前必须确认页面适用机型包含 `21KU0000CD`，不要跨型号刷写。刷 BIOS 会重启，务必接电源、保持电量充足，刷写过程中不要断电。
- 当前 NVIDIA 驱动为 `581.60`。如果更新 BIOS 后 `nvidia-smi` 仍然提示 `GPU access blocked by OS`，请从联想电脑管家或 NVIDIA 官网重新安装/清洁安装 RTX 4050 Laptop 驱动。
- 每次调整后，双击项目根目录的 [check-gpu.bat](check-gpu.bat) 生成检查报告；报告保存在 `gpu-report.txt`。如果 `nvidia-smi` 仍失败且 Vulkan 只列出 Intel，建议联系联想售后检查独显供电/主板。

## 4. 交互说明

| 操作 | 效果 |
| --- | --- |
| 左键拖拽 | 旋转厂区视角 |
| 右键拖拽 / 双指拖动 | 平移 |
| 滚轮 | 缩放 |
| 单击设备 | 打开设备孪生抽屉并聚焦 |
| 单击烟囱 | 打开排放监测总览并定位排口 |
| 单击场景标注 | 切换至对应工段视角 |
| 顶部场景条 | 7 个预设视角 |
| `场景标注` / `暂停` | 显示或隐藏标注、暂停动态特效 |
| `SCENE` 工具组 | 放大、缩小、重置视角、渲染质量、GPU 诊断 |
| 导航：环保 / 能源 / 视频安防 | 打开对应系统面板 |
| `SOFTWARE` 标记 | 打开 GPU 加速修复面板 |
| 启动登录页 | 使用 `admin / Binhe@2026` 进入系统 |
| 顶栏用户头像 | 打开账户菜单，查看当前会话并退出登录 |
| 顶部 `看板` | 收起 / 展开左右信息栏和底部能源条 |
| 顶部 `AI` / `Alt + A` | 打开 / 收起 AI 运营助手 |
| Chatbox 快捷问题 | 一键发起排放风险、能耗、设备预警等分析 |

## 5. 技术结构

```text
src/
├── main.js                 # 启动、加载序列、模块装配
├── style.css               # 工业 HUD、响应式布局、动效
├── data/
│   └── simulation.js       # 演示遥测引擎（排放 / 设备 / 能源 / 日志）
├── scene/
│   ├── viewer.js           # Renderer、相机、OrbitControls、Bloom、FXAA、拾取、标注
│   ├── foundry.js          # 程序化铸铁厂模型、灯光、粒子、动画、静态批处理
│   └── textures.js         # 程序化混凝土 / 钢板 / 烟雾 / 地面标识纹理
├── ui/
│   └── charts.js           # Canvas 曲线图 / Sparkline
├── ui.js                   # Dashboard 绑定、看板收放、弹窗、设备抽屉、视频墙、日志、GPU 诊断
├── aiChat.js               # AI Chatbox、实时遥测压缩与对话 UI
├── auth.js                 # 科幻登录界面、启动门禁、安全会话、账户菜单
└── videoWall.js            # 单画布 4 分屏视频渲染器

server/
├── ai.mjs                  # Vite 中间件：DeepSeek 代理、遥测缓存、限流
└── auth.mjs                # 登录、会话 Cookie、登录限流、AI 鉴权
```

### AI 配置

服务端按以下顺序获取 API Key：

1. 环境变量 `DEEPSEEK_API_KEY`
2. 当前 DSH 凭据 `~/.dsh/.credentials.yaml` 中的 `DEEPSEEK_API_KEY`

可选环境变量：

- `DEEPSEEK_MODEL`：默认 `deepseek-flash`
- `DEEPSEEK_BASE_URL`：默认 `https://api.deepseek.com`
- `AI_ALLOW_LAN=1`：允许局域网访问 `/api/ai/chat`；默认只允许本机回环地址，避免密钥被局域网滥用

登录账号相关环境变量：

- `AUTH_USER`：默认 `admin`
- `AUTH_PASSWORD`：默认 `Binhe@2026`
- `AUTH_NAME`：顶栏显示的姓名，默认 `值班管理员`
- `AUTH_ROLE`：顶栏显示的角色，默认 `OPERATOR · ADMIN`

API Key 只在 Vite 服务端进程中读取，浏览器端只会访问 `/api/ai/chat`，不会接触 Key。登录会话使用 HttpOnly Cookie，AI 的遥测和对话接口会校验会话。

## 6. 渲染与轻量化策略

- **静态批处理**：构建完成后把 923 个同材质静态网格合并为 56 个世界空间批次，保留动态装配体、发光信标与交互代理。
- **实例化**：立柱、屋顶桁架、围栏、辊道、造型箱、除尘器梯子等重复件使用 `InstancedMesh` / 合并几何。
- **几何预算**：低段数圆管、低多边形设备轮廓、程序化纹理，无外部贴图与模型下载。
- **拾取代理**：批处理后的设备使用不可见代理盒做 Raycaster 拾取，保证交互不依赖高面数网格。
- **渲染分级（默认高精度，不自动降级）**：
  - 高精度：DPR ≤ 1.6（高 DPI 下超采样），FXAA，2048 软阴影，Bloom，IBL 0.82。
  - 均衡：DPR ≤ 1.3，FXAA，低强度 Bloom。
  - 轻量：DPR ≤ 1.0，关闭阴影、Bloom 与 FXAA，并隐藏火星、浮尘与部分烟雾粒子。
- **GPU 检测**：读取 `WEBGL_debug_renderer_info`，识别 SwiftShader / WARP 等软件渲染；只提示，不主动降低画质。
- **走样控制**：高分辨率 + FXAA 代替昂贵的 4× MSAA，在保持清晰边缘的同时避免高分屏性能塌陷。
- **视频墙降载**：同一场景一个独立画布，硬件下 1280×720 / 10 fps，软件渲染下 960×540 / 约 5.5 fps；关闭弹窗即停止 RAF。
- **可观测性**：场景角落实时显示 FPS；`SCENE → 渲染质量` 可查看 GPU、实际渲染分辨率、Draw Calls、三角面数和场景对象数。
- **自适应布局**：1920×1080、1600×900、1440×900、1280×720 均有独立布局压缩策略。

## 7. 接入真实系统

当前 `src/data/simulation.js` 会生成与真实网关同构的数据快照。接入时可保留 UI 与场景层，仅替换数据源：

1. **遥测**：用 WebSocket / MQTT / OPC-UA 网关推送最新快照，字段结构参考 `Simulation.snapshot()`。
   - `emissions[]`：id、value、limit、metrics、status、online。
   - `equipment[]`：id、status、power、temp、vibration、todayKwh。
   - `meters[]`：current、today、gas、water、air、history。
   - `logs[]`：时间、级别、来源、内容、操作人。
2. **视频**：把 `VideoWall` 的画面替换为 `<video>` + HLS.js / WebRTC / GB28181 网关；保留通道元数据与叠加层即可。
3. **排放数据**：将 CEMS 的 mg/m³ 与标况流量直接映射到 `metrics`；预警阈值按当地排污许可限值配置。
4. **能源分表**：将电表、燃气流量计、水表、涡街流量计读数映射到 `meters[]`，保留 24 点历史数组供曲线使用。

## 8. 浏览器要求

- 推荐 Chrome / Edge 最新版，开启硬件加速。
- 需要 WebGL2；场景针对独立显卡优化。
- 软件渲染环境下页面仍可运行，但会主动降级并提示硬件加速问题。

---

**数据声明**：演示环境中的排放浓度、设备状态、能耗、日志和视频画面均为仿真数据，不代表真实工厂运行情况。

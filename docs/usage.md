# 使用手册

## 运行模式

| 模式 | 图形栈 | 启动的程序 | 典型用途 |
|---|---|---|---|
| `rviz-vnc` | Xvfb+VNC+noVNC | `rviz2 [-d $SIM_RVIZ_CONFIG]` | 浏览器里看 rviz |
| `gazebo-vnc` | Xvfb+VNC+noVNC | gazebo（GUI 走 VNC） | 浏览器里看/操作 Gazebo |
| `headless` | 无 | gzserver（有 `SIM_WORLD`）或 sleep | CI / 无显示环境 |

模式通过 compose `command:` 或 `docker run` 第一参数指定；也可用环境变量
`SIM_CMD`。传入其它任意命令则直接 exec 该命令（自定义场景）。

## 环境变量全表

| 变量 | 默认 | 说明 |
|---|---|---|
| `SIM_CMD` | `rviz-vnc` | 未给命令参数时的默认模式 |
| `SIM_DISPLAY` | `:99` | X display 编号 |
| `SIM_GEOMETRY` | `1600x1000x24` | `宽x高x色深` |
| `SIM_WEB_PORT` | `6080` | noVNC 网页端口（容器内） |
| `SIM_VNC_PORT` | `5900` | 原始 VNC 端口（容器内） |
| `SIM_VNC_PASSWORD` | `ros` | VNC 密码 |
| `SIM_RVIZ_CONFIG` | 空 | rviz 配置文件路径（`-d`） |
| `SIM_WORLD` | 空 | Gazebo world 文件路径 |

注意：`SIM_WEB_PORT`/`SIM_VNC_PORT` 是**容器内**端口；对外端口用 `docker -p`
映射（如 `-p 6080:6080`、`-p 5901:5900`）。

## 常见问题

- **网页打不开**：`docker logs <c>` 看 `[sim-entrypoint]` 各行是否都启动；
  Xvfb 启动失败通常是 `SIM_GEOMETRY` 格式错（必须是 `WxHxD`）。
- **VNC 客户端连不上**：确认密码是 `SIM_VNC_PASSWORD` 的值。
- **中文乱码**：镜像已带 `zh_CN.UTF-8` locale；应用侧需自行设置 `LANG`。
- **ROS 2 话题不通**：本镜像不带 DDS peer 配置；跨容器发现请让你的项目
  自带 CycloneDDS/FastDDS 配置并挂载，或用 `--net host`。

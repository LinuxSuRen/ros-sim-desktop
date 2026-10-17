# ros-sim-desktop

ROS 2 仿真桌面运行时镜像：**rviz2 / Gazebo Classic + Xvfb + VNC + noVNC**，
一条 `docker run` 在浏览器里打开你的仿真桌面。

- 多架构：`linux/amd64` + `linux/arm64` 单 manifest（aarch64 现场机可直拉）
- 双变体：`rviz`（可视化）与 `gazebo`（物理仿真），共享同一 base 层
- 双 registry：GHCR 主源 + 阿里云镜像源（国内现场机）
- 两种项目接入契约：**内容挂载**（开发态，零 Dockerfile）与**派生镜像**（部署态，`FROM` 即用）——见 [docs/integration.md](docs/integration.md)

## 镜像矩阵

| 变体 | 镜像 | 内容 |
|---|---|---|
| base | `ros-sim-desktop:base` | ros:humble + Xvfb + x11vnc + fluxbox + noVNC + CJK locale |
| rviz | `ros-sim-desktop:rviz-v*` | base + rviz2 + tf2-tools + xacro |
| gazebo | `ros-sim-desktop:gazebo-v*` | base + Gazebo Classic (gazebo_ros_pkgs) + xacro |

tag 规则：`<变体>-v<MAJOR>.<MINOR>.<PATCH>`（发布）、`<变体>-main`（滚动）、
`<变体>-sha-<short>`（可追溯）。禁止在任何项目里 pin `latest`/`:dev`。

## 快速开始

```bash
# rviz：浏览器打开 http://localhost:6080
docker run -d -p 6080:6080 ghcr.io/linuxsuren/ros-sim-desktop:rviz-main

# gazebo + 自带 world（内容挂载模式）
docker run -d -p 6080:6080 \
  -v $PWD/my.world:/opt/sim/worlds/my.world:ro \
  -e SIM_WORLD=/opt/sim/worlds/my.world \
  ghcr.io/linuxsuren/ros-sim-desktop:gazebo-main
```

完整演示见 [examples/compose-demo.yml](examples/compose-demo.yml)。

## 运行模式与环境变量

入口命令三选一：`rviz-vnc`（默认 rviz 变体）/ `gazebo-vnc`（默认 gazebo 变体）/
`headless`（无图形栈，跑 gzserver 或空转，CI 友好）。

| 变量 | 默认 | 说明 |
|---|---|---|
| `SIM_DISPLAY` | `:99` | X display |
| `SIM_GEOMETRY` | `1600x1000x24` | 分辨率×色深 |
| `SIM_WEB_PORT` | `6080` | noVNC 网页端口（容器内） |
| `SIM_VNC_PORT` | `5900` | 原始 VNC 端口（容器内） |
| `SIM_VNC_PASSWORD` | `ros` | VNC 密码 |
| `SIM_RVIZ_CONFIG` | 空 | rviz 配置（`-d`，rviz 变体） |
| `SIM_WORLD` | 空 | world 文件路径（gazebo 变体） |

全表见 [docs/usage.md](docs/usage.md)。

## 与同类项目的差异

对比 [tiryoh/ros2-desktop-vnc](https://github.com/Tiryoh/ros2-desktop-vnc)：
amd64+arm64 多架构、rviz/gazebo 双变体、双 registry 分发、挂载/派生两种
项目接入契约。

## 版本语义

MAJOR＝入口环境变量契约或显示机制变更；MINOR＝新增包/examples；PATCH＝修复。
变更 `SIM_CMD`/环境变量语义须升 MAJOR，并在本仓库 Release Notes 显著标注。

## Roadmap

- Gazebo 新一代（gz-sim Harmonic）变体
- 若未来镜像层加入源码编译，arm64 构建切 native runner（QEMU 届时不可承受）

## License

Apache-2.0。镜像内第三方组件归属见 [NOTICE](NOTICE)。

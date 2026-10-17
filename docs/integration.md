# 项目接入契约

你的机器人项目（URDF/world/rviz 配置/launch）**不属于本仓库**。接入有两种
模式，分别对应开发态与部署态：

## 模式一：内容挂载（开发态，零 Dockerfile）

项目资产以只读 volume 挂进容器，运行时通过环境变量指路：

```yaml
# 你的项目 compose 片段
rviz:
  image: ghcr.io/linuxsuren/ros-sim-desktop:rviz-v1.0.0
  command: rviz-vnc
  ports: ["6080:6080"]
  volumes:
    - ./rviz:/opt/sim/rviz:ro
  environment:
    SIM_RVIZ_CONFIG: /opt/sim/rviz/my_config.rviz

gazebo:
  image: ghcr.io/linuxsuren/ros-sim-desktop:gazebo-v1.0.0
  command: gazebo-vnc
  ports: ["6081:6080"]
  volumes:
    - ./worlds:/opt/sim/worlds:ro
  environment:
    SIM_WORLD: /opt/sim/worlds/my.world
```

适用：日常开发、快速换 world/rviz 配置调试。

## 模式二：派生镜像（部署态，现场机无源码目录）

在你的项目仓库里写一个薄 Dockerfile：

```dockerfile
FROM ghcr.io/linuxsuren/ros-sim-desktop:gazebo-v1.0.0
COPY worlds /opt/sim/worlds
COPY urdf   /opt/sim/urdf
ENV SIM_WORLD=/opt/sim/worlds/default.world
```

由你的项目 CI 构建并推到你自己的 registry。适用：现场部署、镜像内需要
预置资产或额外 apt 包的场景。

## 契约要点

1. **frame/话题约定归项目**：本镜像不约定任何 frame（map/odom/base_link）
   或话题；URDF/launch 带什么就是什么。
2. **DDS 配置归项目**：需要 peer 发现/网段约束时挂载你的 CycloneDDS 配置。
3. **版本 pin 规则**：项目 compose 引用必须带具体版本 tag（`rviz-v1.2.0`），
   禁止 `latest`/`:dev`（部署漂移源）。
4. **升级联动**：本仓库若变更 `SIM_CMD`/`SIM_*` 语义会升 MAJOR 版本并在
   Release Notes 标注；项目侧升级 MAJOR 前请核对 docs/usage.md。

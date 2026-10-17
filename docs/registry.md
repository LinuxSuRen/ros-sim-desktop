# Registry 说明

## 双 registry

| 角色 | 地址 | 用途 |
|---|---|---|
| 主源 | `ghcr.io/linuxsuren/ros-sim-desktop` | CI 构建、发布 |
| 国内镜像 | `registry.cn-hangzhou.aliyuncs.com/linuxsuren/ros-sim-desktop` | 国内/现场 aarch64 机器拉取 |

release tag（`v*.*.*`）构建完成后由 CI（skopeo）把多架构 manifest 原样
搬运到阿里云源，两边内容一致。

## 拉取建议

- 海外 CI：直接 GHCR。
- 国内现场机：优先阿里云源；若拉 GHCR 慢/被墙，用阿里云源。
- 私有镜像拉取需要 `docker login` 对应 registry。

## tag 规则

| tag 形态 | 含义 | 项目引用 |
|---|---|---|
| `<variant>-v<semver>` | 发布版 | ✅ 推荐 pin |
| `<variant>-main` | main 滚动 | 仅尝鲜 |
| `<variant>-sha-<short>` | commit 追溯 | 问题复现 |
| `latest` / `:dev` | — | ❌ 不存在，禁止使用 |

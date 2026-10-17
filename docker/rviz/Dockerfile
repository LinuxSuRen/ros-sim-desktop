# rviz2 visualization variant.
#
# Build (from repo root, after base):
#   docker build -f docker/rviz/Dockerfile -t ros-sim-desktop:rviz-dev .
# CI overrides BASE_IMAGE with the fully-qualified GHCR reference.
ARG BASE_IMAGE=ros-sim-desktop:base
# hadolint ignore=DL3006: the ARG default above carries a tag
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt_with_retry() { \
      for attempt in 1 2 3; do \
        if apt-get update && apt-get install -y --no-install-recommends "$@"; then return 0; fi; \
        echo "[apt] attempt ${attempt} failed, retrying in 10s" >&2; \
        sleep 10; \
      done; \
      return 1; \
    }; \
    apt_with_retry \
      ros-humble-rviz2 \
      ros-humble-tf2-tools \
      ros-humble-xacro \
    && rm -rf /var/lib/apt/lists/*

CMD ["rviz-vnc"]

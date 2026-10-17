# rviz2 visualization variant.
#
# Build (from repo root, after base):
#   docker build -f docker/rviz/Dockerfile -t ros-sim-desktop:rviz-dev .
# CI overrides BASE_IMAGE with the fully-qualified GHCR reference.
ARG BASE_IMAGE=ros-sim-desktop:base
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-rviz2 \
    ros-humble-tf2-tools \
    ros-humble-xacro \
  && rm -rf /var/lib/apt/lists/*

CMD ["rviz-vnc"]

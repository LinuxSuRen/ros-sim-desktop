# Gazebo Classic simulation variant.
#
# Build (from repo root, after base):
#   docker build -f docker/gazebo/Dockerfile -t ros-sim-desktop:gazebo-dev .
# CI overrides BASE_IMAGE with the fully-qualified GHCR reference.
ARG BASE_IMAGE=ros-sim-desktop:base
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-plugins \
    ros-humble-xacro \
  && rm -rf /var/lib/apt/lists/*

ENV ALSOFT_DRIVERS=null

# Default mount point for project-supplied worlds (see docs/integration.md).
RUN mkdir -p /opt/sim/worlds /opt/sim/urdf /opt/sim/rviz

CMD ["gazebo-vnc"]

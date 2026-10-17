# rviz2 visualization variant.
#
# Build (from repo root, after base):
#   docker build -f docker/rviz/Dockerfile -t ros-sim-desktop:rviz-dev .
FROM ros-sim-desktop:base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-rviz2 \
    ros-humble-tf2-tools \
    ros-humble-xacro \
  && rm -rf /var/lib/apt/lists/*

CMD ["rviz-vnc"]

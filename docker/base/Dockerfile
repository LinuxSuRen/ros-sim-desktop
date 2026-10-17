# Common desktop layer: ROS 2 Humble + Xvfb + VNC + fluxbox + noVNC.
#
# Build (from repo root):
#   docker build -f docker/base/Dockerfile -t ros-sim-desktop:base .
FROM ros:humble-ros-base-jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    x11vnc \
    fluxbox \
    novnc \
    websockify \
    x11-utils \
    locales \
    dbus-x11 \
    sudo \
  && rm -rf /var/lib/apt/lists/*

# CJK-capable locales so GUI text renders correctly.
RUN sed -i 's/^# \(en_US\.UTF-8 UTF-8\)/\1/; s/^# \(zh_CN\.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen

# Non-root runtime user (override with `--user` or USER instruction in derived images).
RUN useradd -m -s /bin/bash -G sudo,video sim \
  && echo 'sim:sim' | chpasswd
WORKDIR /home/sim
ENV HOME=/home/sim

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DISPLAY=:99 \
    QT_X11_NO_MITSHM=1 \
    LIBGL_ALWAYS_SOFTWARE=1

COPY docker/entrypoint.sh /usr/local/bin/sim-entrypoint
RUN chmod +x /usr/local/bin/sim-entrypoint

ENTRYPOINT ["sim-entrypoint"]
CMD ["rviz-vnc"]

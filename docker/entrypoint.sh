#!/usr/bin/env bash
# Unified entrypoint for ros-sim-desktop images.
#
# Modes (first argument, or SIM_CMD):
#   rviz-vnc    Xvfb + fluxbox + x11vnc + noVNC, then rviz2
#   gazebo-vnc  Xvfb + fluxbox + x11vnc + noVNC, then gazebo (GUI via VNC)
#   headless    no graphics stack; gzserver only (CI / regression runs)
#
# Changing the semantics of SIM_CMD or any SIM_* variable below requires a
# MAJOR version bump (see README "版本语义").
set -euo pipefail

# Official ros: base images only source ROS in interactive shells (.bashrc);
# non-interactive entrypoints must source it explicitly or ros2/rviz2 are
# not on PATH (the container died instantly in CI because of this).
if [ -f "/opt/ros/${ROS_DISTRO:-humble}/setup.bash" ]; then
  # shellcheck disable=SC1090,SC1091
  source "/opt/ros/${ROS_DISTRO:-humble}/setup.bash"
fi

log() { echo "[sim-entrypoint] $*"; }

MODE="${1:-${SIM_CMD:-rviz-vnc}}"

SIM_DISPLAY="${SIM_DISPLAY:-:99}"
SIM_GEOMETRY="${SIM_GEOMETRY:-1600x1000x24}"
SIM_WEB_PORT="${SIM_WEB_PORT:-6080}"
SIM_VNC_PORT="${SIM_VNC_PORT:-5900}"
SIM_VNC_PASSWORD="${SIM_VNC_PASSWORD:-ros}"
SIM_RVIZ_CONFIG="${SIM_RVIZ_CONFIG:-}"
SIM_WORLD="${SIM_WORLD:-}"
export DISPLAY="$SIM_DISPLAY"

PIDS=()
cleanup() {
  for pid in "${PIDS[@]:-}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM

start_graphics() {
  log "starting Xvfb on $SIM_DISPLAY ($SIM_GEOMETRY)"
  Xvfb "$SIM_DISPLAY" -screen 0 "$SIM_GEOMETRY" -nolisten tcp &
  PIDS+=($!)

  for _ in $(seq 1 20); do
    if xset -q >/dev/null 2>&1; then break; fi
    sleep 0.25
  done

  log "starting fluxbox"
  fluxbox >/dev/null 2>&1 &
  PIDS+=($!)

  log "starting x11vnc on :$SIM_VNC_PORT (password: $SIM_VNC_PASSWORD)"
  x11vnc -display "$SIM_DISPLAY" -forever -shared -rfbport "$SIM_VNC_PORT" \
    -passwd "$SIM_VNC_PASSWORD" -noxrecord -noxdamage -repeat &
  PIDS+=($!)

  log "starting noVNC web client on :$SIM_WEB_PORT"
  websockify --web /usr/share/novnc "$SIM_WEB_PORT" localhost:"$SIM_VNC_PORT" &
  PIDS+=($!)
}

case "$MODE" in
  rviz-vnc)
    start_graphics
    log "starting rviz2${SIM_RVIZ_CONFIG:+ (-d $SIM_RVIZ_CONFIG)}"
    exec rviz2 ${SIM_RVIZ_CONFIG:+-d "$SIM_RVIZ_CONFIG"}
    ;;
  gazebo-vnc)
    start_graphics
    if [ -n "$SIM_WORLD" ]; then
      log "starting gazebo with world $SIM_WORLD"
      exec ros2 launch gazebo_ros gazebo.launch.py world:="$SIM_WORLD" gui:=true
    else
      log "starting gazebo (empty world)"
      exec ros2 launch gazebo_ros gazebo.launch.py gui:=true
    fi
    ;;
  headless)
    if [ -n "$SIM_WORLD" ]; then
      log "starting gzserver headless with world $SIM_WORLD"
      exec ros2 launch gazebo_ros gazebo.launch.py world:="$SIM_WORLD" gui:=false
    else
      log "headless idle (no SIM_WORLD given); sleeping"
      exec sleep infinity
    fi
    ;;
  *)
    # Unknown command: assume it is a user command; run it directly.
    log "executing user command: $*"
    exec "$@"
    ;;
esac

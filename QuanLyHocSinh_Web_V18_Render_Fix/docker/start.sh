#!/bin/bash
set -e
export DISPLAY=:99
# Kích thước màn hình ảo bao phủ cả cửa sổ chính 1200x760 và các cửa sổ phụ cao tới ~920px.
Xvfb :99 -screen 0 1280x960x24 -ac +extension GLX +render -noreset >/tmp/xvfb.log 2>&1 &
sleep 1
fluxbox >/tmp/fluxbox.log 2>&1 &
sleep 1
python3 /opt/launcher.py >/tmp/app.log 2>&1 &
APP_PID=$!
sleep 3
# Tối ưu x11vnc cho thao tác chuột/bàn phím và giảm lượng framebuffer phải truyền.
x11vnc \
  -display :99 \
  -forever -shared -localhost -nopw \
  -rfbport 5900 \
  -xkb -repeat \
  -noxdamage -noxrecord -noxfixes \
  -nonc \
  -wait 3 -defer 3 \
  -threads \
  -encodings 'copyrect tight zrle hextile' \
  >/tmp/x11vnc.log 2>&1 &

PORT="${PORT:-6080}"
exec websockify --web=/usr/share/novnc/ --heartbeat=20 "0.0.0.0:${PORT}" localhost:5900

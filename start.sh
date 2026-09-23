#!/bin/bash
set -Eeuo pipefail

export DISPLAY=:99
PORT="${PORT:-10000}"

log(){ echo "[V18] $*"; }
fatal(){ echo "[V18][FATAL] $*" >&2; exit 1; }

log "1/4 Starting Xvfb"
Xvfb :99 -screen 0 1280x960x24 -ac +extension GLX +render -noreset >/tmp/xvfb.log 2>&1 &
XVFB_PID=$!
trap 'kill ${XVFB_PID:-} ${FLUX_PID:-} ${APP_PID:-} ${VNC_PID:-} 2>/dev/null || true' EXIT

for i in {1..50}; do
  if kill -0 "$XVFB_PID" 2>/dev/null && DISPLAY=:99 xdpyinfo >/dev/null 2>&1; then
    break
  fi
  if [ "$i" -eq 50 ]; then
    cat /tmp/xvfb.log >&2 || true
    fatal "Xvfb was not ready"
  fi
  sleep 0.2
done
log "Xvfb ready"

fluxbox >/tmp/fluxbox.log 2>&1 &
FLUX_PID=$!
sleep 0.5

log "2/4 Starting original V18 Python application"
python3 /opt/launcher.py > >(tee /tmp/app.log) 2> >(tee /tmp/app-error.log >&2) &
APP_PID=$!
sleep 2
if ! kill -0 "$APP_PID" 2>/dev/null; then
  cat /tmp/app.log >&2 || true
  cat /tmp/app-error.log >&2 || true
  fatal "The V18 Python process exited during startup"
fi

log "3/4 Starting x11vnc on 127.0.0.1:5900"
x11vnc \
  -display :99 \
  -rfbport 5900 \
  -listen 127.0.0.1 \
  -forever -shared -nopw \
  -xkb -repeat \
  -noxdamage -noxrecord -noxfixes \
  -wait 3 -defer 3 \
  -threads \
  -encodings 'copyrect tight zrle hextile' \
  > >(tee /tmp/x11vnc.log) 2> >(tee /tmp/x11vnc-error.log >&2) &
VNC_PID=$!

for i in {1..100}; do
  if ! kill -0 "$VNC_PID" 2>/dev/null; then
    cat /tmp/x11vnc.log >&2 || true
    cat /tmp/x11vnc-error.log >&2 || true
    fatal "x11vnc exited before port 5900 became ready"
  fi
  if python3 -c "import socket; s=socket.create_connection(('127.0.0.1',5900),0.2); s.close()" 2>/dev/null; then
    log "VNC port 5900 ready"
    break
  fi
  if [ "$i" -eq 100 ]; then
    cat /tmp/x11vnc.log >&2 || true
    cat /tmp/x11vnc-error.log >&2 || true
    fatal "Timed out waiting for port 5900"
  fi
  sleep 0.2
done

log "4/4 Starting official noVNC proxy on 0.0.0.0:${PORT}"
exec /usr/share/novnc/utils/novnc_proxy --vnc 127.0.0.1:5900 --listen "0.0.0.0:${PORT}" --heartbeat 20

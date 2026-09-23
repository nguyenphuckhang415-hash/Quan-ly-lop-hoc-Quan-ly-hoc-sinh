FROM python:3.12-slim
ENV DEBIAN_FRONTEND=noninteractive PYTHONUNBUFFERED=1 DISPLAY=:99
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-tk xvfb x11vnc novnc websockify fluxbox xdg-utils fonts-dejavu fonts-liberation \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir openpyxl pillow 'qrcode[pil]'
COPY app/Quan_ly_hoc_sinh_V18(2).py /opt/original/Quan_ly_hoc_sinh_V18(2).py
COPY docker/launcher.py /opt/launcher.py
COPY docker/start.sh /opt/start.sh
RUN chmod +x /opt/start.sh
VOLUME ["/data"]
EXPOSE 6080
CMD ["/opt/start.sh"]

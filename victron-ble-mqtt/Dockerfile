ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM $BUILD_FROM

RUN apk add --no-cache python3 py3-pip python3-dev build-base libffi-dev git bluez dbus
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install bleak
RUN git clone https://github.com/AverageJoe89/victron-ble2mqtt.git
RUN cd victron-ble2mqtt && ./cli.py version
RUN mkdir -p /root/victron-ble2mqtt
RUN ln -s /data/victron-ble2mqtt.toml /root/victron-ble2mqtt/victron-ble2mqtt.toml

WORKDIR /data

COPY run.sh /run.sh
COPY data /template

# Workaround for bug #44 victron-ble2mqtt needs iwconfig, but we don't - https://github.com/jedie/victron-ble2mqtt/issues/44
RUN cat <<'EOF' > /bin/iwconfig
#!/bin/sh
exit 0
EOF

RUN chmod +x /bin/iwconfig
RUN chmod +x /run.sh

CMD [ "/run.sh" ]

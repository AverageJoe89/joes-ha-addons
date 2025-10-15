#!/command/with-contenv bashio

CONFIG_PATH=/data/options.json

# Read user config from Home Assistant
MQTT_SERVER="$(bashio::config 'mqtt_server')"
MQTT_PORT="$(bashio::config 'mqtt_port')"
MQTT_USERNAME="$(bashio::config 'mqtt_username')"
MQTT_PASSWORD="$(bashio::config 'mqtt_password')"
MQTT_PUBLISH_THROTTLE="$(bashio::config 'mqtt_publish_throttle')"
MQTT_CONFIG_PUBLISH_THROTTLE="$(bashio::config 'mqtt_config_publish_throttle')"

bashio::log.info "Generating TOML configuration for Victron BLE2MQTT"

# Build TOML
TOML='device_name = "Victron"
publish_throttle_seconds = 1
device_keys = ['

FIRST=true
for secret in $(bashio::config 'victron_secrets'); do
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        TOML+=", "
    fi
    TOML+="\"${secret}\""
done

TOML+=']
[mqtt]
host = "'"${MQTT_SERVER}"'"
port = '"${MQTT_PORT}"'
user_name = "'"${MQTT_USERNAME}"'"
password = "'"${MQTT_PASSWORD}"'"
main_uid = "victron_ble"
publish_config_throttle_seconds = '"${MQTT_CONFIG_PUBLISH_THROTTLE}"'
publish_throttle_seconds = '"${MQTT_PUBLISH_THROTTLE}"'
'

# --- Write TOML to disk ---
echo "${TOML}" > /data/victron-ble2mqtt.toml
cat /template/template-victron-ble2mqtt.toml >> /data/victron-ble2mqtt.toml

bashio::log.info "Config file created at /data/victron-ble2mqtt.toml"

bashio::log.info "Starting Victron BLE2MQTT"

/victron-ble2mqtt/cli.py publish-loop -vv

# Pimoroni Grow Kit - MQTT

Pimoroni's Grow Kit comes with some python samples making it possible to read the sensors data off the board. In this setup we will be reading the
data and submit it to a MQTT broker channel running on a Home Assistance (HA) instance.
This makes it possible to create graphs for your HA dashboard.

![](https://i.imgur.com/MxnsXlt.png)

## Requirements

* A Raspberry Pi (Zero)
* A [Piromoni   Grow Kit](https://shop.pimoroni.com/products/grow)

## Raspberry Pi Preparation

1. Install the Raspberry Pi OS Lite image with [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
2. Create a `SSH` file in the root location of the SD card
3. Create a `wpa_supplicant.conf` file in the root location of the SD card:

    ```bash
    country=NL
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
   
    network={
       ssid="Wifi Network Name"
       scan_ssid=1
       psk="Wifi password"
       key_mgmt=WPA-PSK
    }
    ```

4. Insert the SD card in the Raspberry and power it on. Connect to the raspberry via SSH and rename it to a name of your choice to easily recognize it on your network:

   ```bash
   # SSH connection
   ssh pi@192.168.**.**
       
   # Setup you Pi
   sudo raspi-config
   ```

5. Install Pimoroni's Grow Kit python library including the examples and reboot when the installer asks for it.

   ```bash
   curl -sSL https://get.pimoroni.com/grow | bash
   ```

6. Install the MQTT library

   ```bash
   pip3 install paho.mqtt
   ```

6. Install the repository containing the MQTT messager

   ```bash
   git clone https://github.com/jeroenboumans/PimoroniGrowKit-MQTT
   cd PimoroniGrowKit-MQTT/
   ```

7. Fill in your broker config in the `config.yaml`

   ```bash
   sudo nano config.yaml
   ```

   ```yaml
   broker:
      port: 1883
      host: ...       # 192.168.86.x
      topic: ...      # home/livingroom/plants
   
   auth:
      username: ...   # MQTT username
      password: ...   # MQTT password
   ```


9. Setup the Growkit MQTT watcher via the command below:

   ```bash
   chmod +x setup.sh
   
   ./setup.sh
   ```


## Home Assistant Integration

![](https://i.imgur.com/J89flMq.png)

Every Grow Kit moisture sensor needs to be registered as a sensor in Home Assistant in order to use it. To register it,
use its corresponding index number: 0, 1, 2.
Both moisture and saturation can be read from the topic.

To read data, register the following sensors in your Home Assistant config files:

### Saturation
```yaml
# sensors.yaml: sensor 1 of 3
 - platform: mqtt
   name: "Saturation"
   state_topic: "home/livingroom/plants"
   value_template: "{{ value_json.sensor_0.saturation }}"
   json_attributes_topic: " home/livingroom/plants"
   json_attributes_template: "{{ value_json.sensor_0 | tojson }}"
```

### Moisture
```yaml
# sensors.yaml: sensor 1 of 3
 - platform: mqtt
   name: "Moisture"
   state_topic: "home/livingroom/plants"
   value_template: "{{ value_json.sensor_0.moisture }}"
   json_attributes_topic: " home/livingroom/plants"
   json_attributes_template: "{{ value_json.sensor_0 | tojson }}"
```

### Lux level (board sensor)
```yaml
 - platform: mqtt
   name: "Lux"
   state_topic: "home/livingroom/plants"
   unit_of_measurement: 'Lux'
   value_template: "{{ value_json.light }}"
   json_attributes_topic: "home/livingroom/plants"
   json_attributes_template: "{{ value_json.light }}"
```

WHen set up you can plot the sensors in the HA dashboard using a graph like [kalkih/mini-graph-card](https://github.com/kalkih/mini-graph-card):
```yaml
type: 'custom:mini-graph-card'
name: Moisture Levels
entities:
  - entity: sensor.moisture
    name: Musa
  - entity: sensor.moisture_2
    name: Herbs Mix
  - entity: sensor.moisture_3
    name: Pteris
hours_to_show: 24
line_width: 3
points_per_hour: 4
smoothing: true
color_thresholds: # range of 0 - 30 Hz for moisture
  - value: 15
    color: '#FF0000'
  - value: 5
    color: '#FFFF00'
  - value: 0
    color: '#00FFFF'
logarithmic: true
icon: 'mdi:water'
show:
  icon_adaptive_color: true
  state: true
  legend: true
  average: false
  extrema: true
```
# Pimoroni Grow Kit - MQTT
A python script for Raspberry Pi submitting sensor data to a MQTT topic. This can easily be picked up by a home assistant sensor configuration.

![](https://i.imgur.com/qMEm57R.png)
A Home Assistent state listener made with Python powered by the Home Asssistent websocket API. Each script contains of two parallel processes:
- Logger: when configured states change value the logger starts outputting these.
- Listener: the handler to listen and write states changes to memory.

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

4. Insert the SD card in the Raspberry power it on. Connect to the raspberry using ssh and name it to easily recognize it on your network:

    ```bash
    $ ssh pi@192.168.86.26

    $ sudo raspi-config
    ```

5. Install th dependencies

    ```bash
    $ sudo apt update
    $ sudo apt install python3-pip
    $ pip3 install asyncio paho-mqtt
    $ pip3 install -U PyYAML
    ```
6. Install Pimoroni's Grow Kit python library

    ```bash
    $ curl -sSL https://get.pimoroni.com/grow | bash
    ```   

6. Install the repository

    ```bash
    $ git clone https://github.com/jeroenboumans/PimoroniGrowKit-MQTT
    ```

7. Fill in your broker config in the `config.yaml`

## Run in background

```bash
sudo chmod +x watcher.py
python3 watcher.py &
```

# Read as sensor in Home Assistant

![](https://i.imgur.com/UL9don8.png)

Every Grow Kit moisture sensor needs to be registered as a sensor in Home Assistant.
Both moisture and saturation can be read from the topic. 

To read data, register the following sensors in your Home Assistant config files:

## Saturation
```yaml
# sensors.yaml
 - platform: mqtt
   name: "Saturation"
   state_topic: "home/livingroom/plants"
   value_template: "{{ value_json.sensor_0.saturation }}"
   json_attributes_topic: " home/livingroom/plants"
   json_attributes_template: "{{ value_json.sensor_0 | tojson }}"
```

## Moisture 
```yaml
# sensors.yaml
 - platform: mqtt
   name: "Moisture"
   state_topic: "home/livingroom/plants"
   value_template: "{{ value_json.sensor_0.moisture }}"
   json_attributes_topic: " home/livingroom/plants"
   json_attributes_template: "{{ value_json.sensor_0 | tojson }}"
```

## Lux level
```yaml
 - platform: mqtt
   name: "Lux"
   state_topic: "home/livingroom/plants"
   unit_of_measurement: 'Lux'
   value_template: "{{ value_json.light }}"
   json_attributes_topic: "home/livingroom/plants"
   json_attributes_template: "{{ value_json.light }}"
```

All three sensor's data can be loaded in your view using [kalkih/mini-graph-card](https://github.com/kalkih/mini-graph-card):
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

import time
import json
import yaml;
import ltr559
from grow.moisture import Moisture
import paho.mqtt.client as mqtt


def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))
    print(client.subscribe(broker().get('topic')))


def on_message(client, userdata, msg):
    print(msg.topic + " " + str(msg.payload))


def load_config():
    with open('config.yaml') as f:
        return yaml.load(f)


def broker():
    return load_config().get('broker')


def auth():
    return load_config().get('auth')


config = load_config()
broker = broker()
auth = auth()

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.username_pw_set(auth.get('username'), auth.get('password'))
client.connect(broker.get('host', 'homeassistant.local'), broker.get('port', 1883), 60)

print("Start submitting sensor data on MQTT topic {}".format(broker.get('topic')))

sensors = [Moisture(1), Moisture(2), Moisture(3)]
light = ltr559.LTR559()

while True:

    i = 0
    payload = {"light": light.get_lux()}
    for i in range(0, len(sensors)):
        payload["sensor_{}".format(i)] = {
            "moisture": sensors[i].moisture,
            "saturation": sensors[i].saturation
        }

    client.publish(broker.get('topic'), json.dumps(payload))

    print(json.dumps(payload))

    time.sleep(30)

client.loop_forever()
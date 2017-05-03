
docker run -d --name="mqtt" -p 8883:8883 -p 9001:9001 -v /etc/letsencrypt:/etc/letsencrypt -v /home/steve/homeassistant/mosquitto.conf:/mosquitto/config/mosquitto.conf
-v /home/steve/homeassistant/mosquitto/data:/mosquitto/data -v /home/steve/homeassistant/log:/mosquitto/log eclipse-mosquitto

docker run -d --name="home-assistant" -v /etc/letsencrypt:/etc/letsencrypt -v /home/steve/homeassistant:/config -v /etc/localtime:/etc/localtime:ro --device=/dev/ttyUSB0:/zwaveusbstick:rwm --net=host homeassistant/home-assistant


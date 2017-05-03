
docker run -d --name="mqtt" -p 1883:1883 -p 9001:9001 -v /home/steve/homeassistant/mosquitto.conf:/mosquitto/config/mosquitto.conf 
-v /mosquitto/data -v /mosquitto/log eclipse-mosquitto
docker run -d --name="home-assistant" -v /etc/letsencrypt:/etc/letsencrypt -v /home/steve/homeassistant:/config -v /etc/localtime:/etc/localtime:ro --device=/dev/ttyUSB0:/zwaveusbstick:rwm --net=host homeassistant/home-assistant


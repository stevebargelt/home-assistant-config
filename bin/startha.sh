docker run -d --name="mqtt-ext" -p 8083:8083 -p 8883:8883 -v /etc/letsencrypt:/etc/letsencrypt -v /home/steve/homeassistant/mosquitto-ext.conf:/mosquitto/config/mosquitto.conf -v /etc/ssl/certs/DST_Root_CA_X3.pem:/mosquitto/DST_Root_CA_X3.pem -v /home/steve/homeassistant/pwfile:/etc/mosquitto/pwfile -v /mosquitto/data -v /mosquitto/log eclipse-mosquitto
docker run -d --name="mqtt-int" -p 1883:1883 -v /home/steve/homeassistant/mosquitto-int.conf:/mosquitto/config/mosquitto.conf -v /etc/ssl/certs/DST_Root_CA_X3.pem:/mosquitto/DST_Root_CA_X3.pem -v /mosquitto/data -v /mosquitto/log eclipse-mosquitto
docker run -d --name="influxdb" -p 8086:8086 \
      -v $PWD:/var/lib/influxdb \
      influxdb
docker run -d --name="home-assistant" -v /etc/letsencrypt:/etc/letsencrypt -v /home/steve/homeassistant:/config -v /etc/localtime:/etc/localtime:ro --device=/dev/ttyUSB0:/zwaveusbstick:rwm --net=host homeassistant/home-assistant



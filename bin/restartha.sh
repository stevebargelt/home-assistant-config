docker stop home-assistant
docker rm home-assistant
docker run --restart=always -d --name="home-assistant" -v /etc/letsencrypt:/etc/letsencrypt -v /home/steve/homeassistant:/config -v /etc/localtime:/etc/localtime:ro --device=/dev/ttyUSB0:/zwaveusbstick:rwm --net=host homeassistant/home-assistant:dev

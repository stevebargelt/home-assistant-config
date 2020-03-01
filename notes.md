# Renew TLS Certificates

Open Port 80 on Unifi (Settings - Routing & Firewall - Port Forwarding)

```shell

make stop

sudo docker run -it --rm -p 80:80 --name certbot -v "/Users/steve/ha/letsencrypt:/etc/letsencrypt" -v "/Users/steve/ha/letsencrypt:/var/lib/letsencrypt" certbot/certbot certonly --standalone --preferred-challenges http-01 --email steve@bargelt.com -d home.bargelt.com

make run

docker exec -it ha_home-assistant_1 chmod -R 0755 /etc/letsencrypt/live/home.bargelt.com/privkey.pem
docker exec -it ha_home-assistant_1 chmod -R 0755 /etc/letsencrypt/live/home.bargelt.com/fullchain.pem

docker restart ha_home-assistant_1

```

Close Port 80 on Unifi (Settings - Routing & Firewall - Port Forwarding)


## This is regarding dasher... but might apply to emulate hue as well??


Yes, I am using --network=host in my docker run command line.

My HASS container has its own dedicated lan ip I have setup with a macvlan network. The HASS container does not repsond to pings but the amazon-dash container does correctly resolve ip address if I test it through its shell. I am using the exact same amazon-dash.yml file in both container and standalone version. Standalone works fine.

Update: I have done a little playing around with network settings and I find if I use --network=macvlan (the same network the HASS container is on and part of my lan /24 subnet) it works fine! Funny though, because I have other containers using the host network which work perfectly.

Maybe there is something super sensitive with the network implementation?

------

## Dasher

docker run -it --network=host -v /Users/steve/ha/dasher/config:/config/ nekmo/amazon-dash:latest amazon-dash discovery


docker run -it --network=host \
             -v /Users/steve/ha/dasher/config:/config/ \
             nekmo/amazon-dash:latest \
             amazon-dash run --ignore-perms --root-allowed \
                             --config /config/amazon-dash.yml


## OpenZwave MQTT

docker run --rm -it -p 8091:8091 --device=/dev/ttyUSB0 -v $(pwd)/store:/usr/src/app/store robertslando/zwave2mqtt:latest

## ESPHome

Since no love sharing USB Devices on a Mac... we must download the bin fine and:

```shell

esptool.py --port /dev/tty.SLAB_USBtoUART write_flash 0x0 ~/Downloads/testdummy.bin

```

## Anova

docker exec -it 71f9f45c8f43 bash
docker exec -it 71f9f45c8f43 cd /config/scripts/anova.py/ && pip3 install -r requirements.txt
docker exec -it 71f9f45c8f43 /config/scripts/anova.py/pip3 install -e .

pip3 install -r requirements.txt
pip3 install -e .

Anova = way more hassle than it was worth. When not plugged in = a ton of errors in HA logs. Revisit in future?

## HACS (Home Assistant Community Store)

FROM:
https://hacs.netlify.com/installation/terminal/

docker exec -it ha_home-assistant_1 bash
git clone https://github.com/custom-components/hacs.git hacs_temp
cd hacs_temp
git checkout $(git describe --tags --always $(git rev-list --tags --max-count=1000) | grep -e "[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 1)
cd ../
cp -r hacs_temp/custom_components/hacs hacs
rm -R hacs_temp

Create github token
06f3b7c05e15e97f2b8f2d97a32c8644a359ced9

<!-- ## Alexa Media Player

Now in HACS

docker exec -it ha_home-assistant_1 bash

git clone https://github.com/custom-components/alexa_media_player.git -->

## Influx DB


```bash
docker exec -it ha_influxdb_1 bash

influx

SHOW DATABASES
CREATE DATABASE homeassistant

CREATE USER homeassistant WITH PASSWORD 'correcthorsebatterystaple'

GRANT ALL ON homeassistant TO homeassistant

exit
exit
```
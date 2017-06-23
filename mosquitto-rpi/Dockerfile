FROM resin/rpi-raspbian:jessie
MAINTAINER Steve Bargelt <steve@bargelt.com>

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget

RUN wget -q -O - http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key | apt-key add -
RUN wget -q -O /etc/apt/sources.list.d/mosquitto-jessie.list http://repo.mosquitto.org/debian/mosquitto-jessie.list
RUN apt-get update && apt-get install -y mosquitto && rm -rf /var/lib/apt/lists/* 

#RUN adduser --system --disabled-password --disabled-login mosquitto

RUN mkdir -p /mosquitto/config /mosquitto/data /mosquitto/log && \
	# cp /etc/mosquitto/mosquitto.conf /mosquitto/config && \
	  chown -R mosquitto:mosquitto /mosquitto

COPY docker-entrypoint.sh / && \
     chmod +x /docker-entrypoint.sh && \
     chown -R mosquitto:mosquitto /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
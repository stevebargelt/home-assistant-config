FROM hypriot/rpi-node
MAINTAINER Steve Bargelt <steve@bargelt.com>

RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y libpcap-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

#install dasher
RUN cd /usr/src/app && export GIT_SSL_NO_VERIFY=1 && \
    git config --global http.sslVerify false && \
    git clone https://github.com/maddox/dasher.git .

# Install app dependencies
RUN npm install

# Bundle app source
CMD cd /usr/src/app && npm run start

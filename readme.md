# [![Build Status](https://travis-ci.org/stevebargelt/home-assistant-config.svg?branch=master)](https://travis-ci.org/stevebargelt/home-assistant-config) Home Assistant Configuration

[@stevebargelt](http://www.twitter.com/stevebargelt)

docker-compose -p ha up -d

docker-compose -p ha stop

## Kitchen Accent Lights

Example (color is approximate color of all other kitchen lights)

```
{"entity_id":"light.kitchen_accent",
"effect":"solid",
"rgb_color": [255, 172, 93],
"brightness":80
}
```
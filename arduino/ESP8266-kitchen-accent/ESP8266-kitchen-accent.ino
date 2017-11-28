#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include <PubSubClient.h>
#include <Adafruit_NeoPixel.h>
#include <ArduinoJson.h>
#include <Time.h>
#include "NeoPatterns.cpp"

#define LED_PIN 5    // D1 on Node MCU ESP8266
#define MOTION_PIN 0 // D3 on Node MCU ESP8266
#define NUM_LEDS 200

/************************** Networking Information *************************************/
const char* ssid = "FBI Surveillance Van #2.4";
const char* password = "BigBossWreckersWiFi";
const char* mqtt_server = "192.168.1.5";
const char* host_name = "esp8266-KitchenAccent";

/************* MQTT TOPICS (change these topics as you wish)  **************************/
const char* light_state_topic = "ha/kitchenaccent";
const char* light_set_topic = "ha/kitchenaccent/set";

const char* motion_state_topic = "ha/kitchenmotion";

/****************************************FOR JSON***************************************/
const int BUFFER_SIZE = JSON_OBJECT_SIZE(10);
#define MQTT_MAX_PACKET_SIZE 512

/********************************** GLOBALS for LEDs ********************************/
const char* on_cmd = "ON";
const char* off_cmd = "OFF";
bool stateOn = false;

/********************************* PIR MOTION GLOBALS *********************************/
int pirState = LOW;             // we start, assuming no motion detected
int val = 0;                    // variable for reading the pin status


/************************************* OTHER GLOBALS *********************************/
WiFiClient espClient;
PubSubClient client(espClient);
//Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);
unsigned long StartTime;
unsigned long CurrentTime;
unsigned long ElapsedTime;

/********************************** Init our LED Strip ******************************/
void StripComplete(); //callback for the completion of a pattern
NeoPatterns strip(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800, &StripComplete);

void setup()
{
  Serial.begin(115200);
  Serial.println("Booting");
  Serial.println("Calling setup_wifi()");
  setup_wifi(); 
  Serial.println("Calling setup_OTA()");
  setup_OTA();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callbackMQTT);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH); //turn built-in LED OFF
  pinMode(LED_PIN, OUTPUT);
  pinMode(MOTION_PIN, INPUT);
  
  strip.begin(); // This initializes the NeoPixel library.
  strip.Solid(strip.Color(0,0,0)); //off

}
 
void loop()
{
  if (!client.connected()) {
    reconnect();
  }
  
  if (WiFi.status() != WL_CONNECTED) {
    delay(1);
    Serial.print("WIFI Disconnected. Attempting reconnection.");
    setup_wifi();
    return;
  }
  
  ArduinoOTA.handle();
  client.loop(); 
        
  val = digitalRead(MOTION_PIN);  // read input value
  if (val == HIGH) {            // check if the input is HIGH
    digitalWrite(LED_BUILTIN, LOW); //turn built-in LED ON
    if (pirState == LOW) {
      // we have just turned on
      unsigned long StartTime = millis();
      Serial.print("Motion detected! | ");
      Serial.println(StartTime);
      // We only want to print on the output change, not state
      client.publish(motion_state_topic, "ON");
      pirState = HIGH;
    }
  } else {
    digitalWrite(LED_BUILTIN, HIGH); //turn built-in LED OFF
    //Serial.println("val == LOW");
    if (pirState == HIGH){
      // we have just turned of
      ElapsedTime = millis() - StartTime;
      Serial.print("Motion ended! | ");
      Serial.println(ElapsedTime);
      // We only want to print on the output change, not state
      client.publish(motion_state_topic, "OFF");
      pirState = LOW;
    }
  }

  strip.Update();
  
} //end of void loop()

//------------------------------------------------------------
//Completion Routines - get called on completion of a pattern
//------------------------------------------------------------

// Strip Completion Callback
void StripComplete()
{
    //strip.Color1 = strip.Wheel(random(255));
}

/********************************** START PROCESS JSON*****************************************/
bool processJson(char* message) {
  StaticJsonBuffer<BUFFER_SIZE> jsonBuffer;

  JsonObject& root = jsonBuffer.parseObject(message);

  const char* effect = "";
  const char* dir = "";
  byte red, green, blue, red2, green2, blue2;
  uint8_t interval;
  uint16_t steps;
  uint32_t color1, color2;
  
  if (!root.success()) {
    Serial.println("parseObject() failed");
    return false;
  }

  if (root.containsKey("state")) {
    
    if (strcmp(root["state"], on_cmd) == 0) {
      stateOn = true;
    }
    else if (strcmp(root["state"], off_cmd) == 0) {
      stateOn = false;
    }
  }

//  if (root.containsKey("brightness")) {
//    brightness = root["brightness"];
//  } else {
//    brightness = 0; 
//  }

  if (root.containsKey("color")) {
    red = root["color"]["r"];
    green = root["color"]["g"];
    blue = root["color"]["b"];
    color1 = strip.Color(red, green, blue);
  }
  
//  if (root.containsKey("color2")) {
//    red = root["color2"]["r"];
//    green = root["color2"]["g"];
//    blue = root["color2"]["b"];
//    //Mapping color2 red, green, and blue based on brightness
//    adjRed = map(red2, 0, 255, 0, brightness);
//    adjGreen = map(green2, 0, 255, 0, brightness);
//    adjBlue = map(blue2, 0, 255, 0, brightness);
//    color2 = strip.Color(adjRed, adjGreen, adjBlue);    
//  } else {
//    color2 = strip.Color(adjRed/2, adjGreen/2, adjBlue/2);
//  }

  if (root.containsKey("effect")) {
    effect = root["effect"];
  } else {
    effect = "SOLID";
  }

  if (root.containsKey("direction")) {
    dir = root["direction"];
  } else {
    dir = "FORWARD";
  }
  
  if (root.containsKey("transition")) {
    interval = root["transition"];
  } else {
    interval = 50;
  }
  
  if (root.containsKey("steps")) {
    steps = root["steps"];
  }

  processMessage(effect, interval, dir, steps, color1, color2);
  
  return true;
}

bool processMessage(const char* effect, uint8_t interval, const char* dir, uint16_t steps, uint32_t color1, uint32_t color2)
{
   
  direction Direction;

  if (!stateOn) {
    Serial.println("Received OFF");
    strip.Solid(strip.Color(0,0,0));
    strip.show();
  }
  else {
    Serial.println("Received ON");
    if (dir == "REVERSE") {
      Direction = REVERSE;
    } else {
      Direction = FORWARD;
    }
    Serial.print("Received effect: ");
    Serial.println(effect);
      
    //{ RAINBOW_CYCLE, THEATER_CHASE, COLOR_WIPE, SCANNER, FADE, CANDY_CANE, SOLID };
    if (strcmp(effect, "RAINBOW_CYCLE") == 0) {
       strip.RainbowCycle(random(0,10));
    } else if (strcmp(effect, "FADE") == 0) {
      strip.Fade(color1, color2, 50, interval, Direction);
    } else if (strcmp(effect, "THEATER_CHASE") == 0) {
      strip.TheaterChase(color1, color2, interval, Direction);
    } else if (strcmp(effect, "SCANNER") == 0) {
      strip.Scanner(color1, interval);
    } else if (strcmp(effect, "COLOR_WIPE") == 0) {
      strip.ColorWipe(color1, interval, Direction);
    } else if (strcmp(effect, "CANDY_CANE") == 0) {
      Serial.println("In CANDY_CANE");
      strip.CandyCane(8, interval); // width of 8
    } else { //default to the Solid Pattern
        strip.Solid(color1);
    }
  }

  return true;
  
} //end of processMessage

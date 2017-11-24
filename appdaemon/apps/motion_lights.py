import appdaemon.appapi as appapi

# Args:
#
# sensor: binary sensor to use as trigger
# entity_on : entity to turn on when detecting motion, can be a light, script, scene or anything else that can be turned on
# entity_off : entity to turn off when detecting motion, can be a light, script or anything else that can be turned off. Can also be a scene which will be turned on
# delay: amount of time after turning on to turn off again. If not specified defaults to 60 seconds.

class MotionLights(appapi.AppDaemon):

  def initialize(self):
    
    self.handle = None
    
    # Subscribe to sensors
    if "sensor" in self.args:
      self.listen_state(self.motion, self.args["sensor"])
    else:
      self.log("No sensor specified, doing nothing")
    
  def motion(self, entity, attribute, old, new, kwargs):
    if new == "on":
      if "entity_on" in self.args:
        self.log("Motion detected: turning {} on".format(self.args["entity_on"]))
        self.turn_on(self.args["entity_on"])
      if "delay" in self.args:
        delay = self.args["delay"]
      else:
        delay = 60
      self.cancel_timer(self.handle)
      self.handle = self.run_in(self.light_off, delay)
  
  def light_off(self, kwargs):
    if "entity_off" in self.args:
        self.log("Turning {} off".format(self.args["entity_off"]))
        self.turn_off(self.args["entity_off"])
        
  def cancel(self):
    self.cancel_timer(self.handle)
      

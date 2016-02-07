#include "Arduino.h"
#include "QueueList.h"
#include "MidiServer.h"

MidiServer midiServer = MidiServer();
ScratchData myScratch;

void setup(void)
{
  Bean.enableWakeOnConnect(true);
  Serial.begin(115200);
  midiServer.init();
  delay(6000);
  Serial.println("Starting midi events loop");
  
}


//------------------Main Loop---------------------------------
void loop() {
  if(!Bean.getConnectionState()){ Bean.sleep(5000); }
  midiServer.handleEvents();
  
}


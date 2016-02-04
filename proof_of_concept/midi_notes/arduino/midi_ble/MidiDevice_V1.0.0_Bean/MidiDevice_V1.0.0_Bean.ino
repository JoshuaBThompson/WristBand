#include "Arduino.h"
#include "QueueList.h"
#include "MidiServer.h"

MidiServer midiServer = MidiServer();
ScratchData myScratch;

void setup(void)
{
  Serial.begin(115200);
  midiServer.init();
  Serial.println("Starting midi events loop");
  
}


//------------------Main Loop---------------------------------
void loop() {
  midiServer.handleEvents();
  
}


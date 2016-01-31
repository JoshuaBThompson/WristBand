#include "Arduino.h"
#include "QueueList.h"
#include "MidiServer.h"

MidiServer midiServer = MidiServer();

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





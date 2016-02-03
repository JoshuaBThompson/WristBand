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
  /*
  ScratchData thisScratch = Bean.readScratchData(1);
  for(int i = 0; i<thisScratch.length; i++){
    Serial.print(thisScratch.data[i]);
  }
  Serial.println(" ... ");
  */
}





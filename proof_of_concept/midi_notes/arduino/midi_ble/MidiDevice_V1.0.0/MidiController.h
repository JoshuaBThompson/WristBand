/*
MidiController.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiController_h
#define MidiController_h

#include "Arduino.h"
#include "MidiSensor.h"
#include "MidiProtocol.h"

class MidiController
{
  public:
    
    //Methods
    MidiController(void);
    void init(void);
    void reset(void);
    void changeNoteChannel(byte channel);
    void changeNote1Number(byte number);
    void changeNote2Number(byte number);
    void changeNoteVelocity(byte velocity);
    void changeNoteMode(char modeNumber);
    void changeEventType(byte eventType);
    void changeEventSource(char sourceNumber);
    void changeBeatFilterAverageCount(char averageCount);
    void changeBeatFilterMaxCount(char maxCount);
    void changeBeatFilterMaxAmp(char maxAmp);
    void changeButtonFunction(char functionNumber);
    
    //variables
    MidiSensor midiSensor;
    MidiProtocol midiProtocol; //contains methods to generate/parse communication protocol message
};

#endif // MidiController_h



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
    MidiDeviceCmds(void);
    void init(void);
    void reset(void);
    void changeNoteChannel(char channel);
    void changeNoteNumber(char number);
    void changeNoteMode(char modeNumber);
    void changeNoteVelocity(char velocity);
    void changeMode(char channel);
    void changeCCFunction(char functionNumber);
    void changeCCSensor(char sensorNumber);
    void changeFilterAverageCount(char averageCount);
    void changeFilterMaxCount(char maxCount);
    void changeFilterMaxAmp(char maxAmp);
    void changeButtonFunction(char functionNumber);
    
    //variables
    MidiSensor midiSensor;
    MidiProtocol midiProtocol; //contains methods to generate/parse communication protocol message
};

#endif // MidiController_h



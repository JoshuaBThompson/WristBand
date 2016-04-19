/*
MidiController.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiController_h
#define MidiController_h

#include "Arduino.h"
#include "MidiSensor.h"
#include "MidiProtocol.h"

//----------Define Change Method Numbers (can be used by MidiServer for callbacks)
#define ChangeNoteChannel               0
#define ChangeNote1Number               1
#define ChangeNote2Number               2
#define ChangeNoteVelocity              3
#define ChangeNoteMode                  4
#define ChangeEventType                 5
#define ChangeEventSource               6
#define ChangeBeatFilterAverageCount    7
#define ChangeBeatFilterMaxCount        8
#define ChangeBeatFilterMaxAmp          9
#define ChangeButtonFunction            10




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




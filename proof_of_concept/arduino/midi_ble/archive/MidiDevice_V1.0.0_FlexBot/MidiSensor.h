/*
MidiSensor.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiSensor_h
#define MidiSensor_h

#include "Arduino.h"
#include "ImuFilter.h"
#include "MotionFilter.h"
#include "Common.h"
#include "QueueList.h"


//Note 
#define NOTE_ON_BYTE        (byte)0x90 //ch1
#define NOTE_OFF_BYTE       (byte)0x80 //ch1
#define NOTE_CHANNEL              0
#define NOTE_VELOCITY       (byte)0x7F //note velocity 0 - 127
#define NOTE1_NUMBER        (byte)65
#define NOTE2_NUMBER        (byte)45

//Generic Event
#define DEFAULT_EVENT_STATUS_BYTE (byte)0xB0 //cc ch1
#define DEFAULT_EVENT_DATA_BYTE1  (byte)0x07 //volume cc control mode change channel 1
#define DEFAULT_EVENT_DATA_BYTE2  (byte)0x00 //volume at 0 (from 0 - 127)
#define DEFAULT_EVENT_CHANNEL             0 //ch1

//Midi Message List 
#define MIDI_MESSAGE_LIST_FIRST (byte)0x80 //note off
#define MIDI_MESSAGE_LIST_LAST  (byte)0xF0 //system reset (not yet implemented)

//Timing
#define IntervalTime  35 //millisec
#define NoteOffMaxTimeDelay 300 //millisec

/*********MidiSensor Struct
 * Defines structure of MidiSensor object 
 * Note On events
 * Note Off events
 * Generic midi events
 * Button
 * sources and mode of note event values
***********/

//modes
typedef enum {ROTATION=0, SINGLE=1} note_modes_t;
typedef enum {EN_CC=0, NOTE=1, PAUSE=2, START=3} button_func_sources_t;

//generic midi event structure (note on, off, cc volume change...etc)
typedef struct {
  bool valid;
  byte statusByte;
  byte dataByte1;
  byte dataByte2;
} midi_event_t;

//general params for general events
typedef struct {
  sources_t source;
  axis_t axis;
  char channel;
} event_params_t;


//general params for notes
typedef struct {
  note_modes_t mode;
  sources_t source;
  axis_t axis;
  byte note1Number;
  byte note2Number;
  byte channel;
  byte velocity;
} note_params_t;


//button function data structure
typedef struct {
  button_func_sources_t source;
  midi_event_t event;
  byte channel;
} button_func_t;

//note on / off struct that uses note ptr
typedef struct {
  midi_event_t note;
  bool enabled;
} note_on_t;

typedef struct {
  midi_event_t note;
  bool enabled;
  bool set;
  unsigned long setTime; //millis
  unsigned short maxTimeDelay; //millis
} note_off_t;


typedef struct {
  button_func_t button;
  note_params_t noteParams;
  event_params_t eventParams;
  note_on_t noteOn;
  note_off_t noteOff;
  midi_event_t event;
  midi_event_t blankEvent;
  unsigned long currentTime, prevTime;
  int intervalTime; // should be set to ~35 millis
} sensor_model_t;

class MidiSensor
{
  public:
    //Methods
    MidiSensor(void);
    void init(void);
    void reset(void);
    void resetNoteParams(void);
    void resetEventParams(void);
    void resetBlankEvent(void);
    void updateNoteOnState(void);
    void updateEventState(void);
    void updateNoteOffState(void);
    void updateState(void);
    void updateNoteOnNumber(void);
    void updateNoteOffNumber(void);
    void updateNoteOffQueue(void);
    void updateNoteOnQueue(void);
    void setMidiNoteMode(char modeNumber);
    void setRotationAxis(char axisNumber);
    void setMidiEventAxis(char axisNumber);
    void setMidiEventSource(char sourceNumber);
    void setMidiNoteAxis(char axisNumber);
    void setMidiNoteSource(char sourceNumber);
    void setNote1Number(byte noteNumber);
    void setNote2Number(byte noteNumber);
    void setNoteChannel(byte channel);
    void setNoteVelocity(byte velocity);
    void setEventChannel(byte channel);
    void setEventType(byte eventType);
    void setEventData(byte eventData);
    midi_event_t readEvent(void);
    
    
    //attributes
    // create a queue of bool for FIFO of midi data
    QueueList <midi_event_t> midiEventQueue;
    sensor_model_t model;
    MotionFilter motionFilter; //wrapper around beat and rotation filter
};

#endif // MidiSensor_h




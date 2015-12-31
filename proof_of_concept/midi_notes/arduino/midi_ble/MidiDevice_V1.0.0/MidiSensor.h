/*
MidiSensor.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiSensor_h
#define MidiSensor_h

#include "Arduino.h"
#include "ImuFilter.h"
#include "MotionFilter."
#include "QueueList.h"


#define IntervalTime  35.0 //millisec to wait between udpateState loop
#define NOTE_ON_BYTE  (byte)0x90 //ch1
#define NOTE_OFF_BYTE (byte)0x80 //ch1
#define DEFAULT_CHANNEL 0
#define NOTE_VELOCITY_BYTE  (byte)0x7f //note velocity 0 - 127

/*********MidiSensor Struct
 * Defines structure of MidiSensor object 
 * Note On events
 * Note Off events
 * Generic midi events
 * Button
 * sources and mode of note event values
***********/

//source of motion data for a midi event
typedef enum {ACCEL_X=0, ACCEL_Y=1, ACCEL_Z=2, GYRO_X=3, GYRO_Y=4, GYRO_Z=5, MAG_X=6, MAG_Y=7, MAG_Z=8} sources_t;
typedef enum {ROTATION=0, SINGLE=1} note_modes_t;
typedef enum {EN_CC=0, NOTE=1, PAUSE=2, START=3} button_func_sources_t;

//generic midi event structure (note on, off, cc volume change...etc)
typedef struct {
  byte statusByte;
  byte dataByte1;
  byte dataByte2;
} midi_event_t;

//general params for general events
typedef struct {
  sources_t source;
  char channel;
} event_params_t;


//general params for notes
typedef struct {
  note_modes_t mode;
  sources_t source;
  byte note1Number;
  byte note2Number;
  char channel;
  char velocity;
} note_params_t;


//button function params
typedef struct {
  button_func_sources_t source;
} button_func_params_t;

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
} note_off_t;


typedef struct {
  button_func_params_t button;
  note_params_t noteParams;
  event_params_t eventParams;
  note_on_t noteOn;
  note_off_t noteOff;
  midi_event_t event;
  unsigned long currentTime, prevTime;
  int intervalTime; // should be set to ~35 millis
} sensor_model_t;

class MidiSensor
{
  public:
    //Methods
    MidiSensor(void);
    void init(void);
    void initModel(void);
    void reset(void);
    
    //attributes
    // create a queue of bool for FIFO of midi data
    QueueList <midi_event_t> midiEventQueue;
    sensor_model_t model;
    MotionFilter motionFilter; //wrapper around beat and rotation filter
};

#endif // MidiSensor_h



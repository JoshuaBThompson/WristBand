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

/*********MidiSensor Struct
 * Defines structure of MidiSensor object 
 * Note On events
 * Note Off events
 * Generic midi events
 * Button
 * sources and mode of note event values
***********/


//source of motion data for a midi event
typedef enum {ACCEL_X, ACCEL_Y, ACCEL_Z, GYRO_X, GYRO_Y, GYRO_Z, MAG_X, MAG_Y, MAG_Z} sources_t;
typedef enum {ROTATION, SINGLE} note_modes_t;
typedef enum {EN_CC, NOTE, PAUSE, START} button_func_sources_t;

//generic midi event structure (note on, off, cc volume change...etc)
typedef struct {
  char statusByte;
  char dataByte1;
  char dataByte2;
  sources_t source;
} midi_event_t;

//note is just a type of midi event, we will add a mode param that determines if note are made based on rotation angle and beat or just a beat
typedef struct {
  midi_event_t event;
  note_modes_t mode;
} midi_note_event_t;

//button function params
typedef struct {
  button_func_sources_t source;
} button_func_params_t;

//note on / off struct that uses note ptr
typedef struct {
  midi_note_event_t note;
  bool enabled;
} note_on_t;

typedef struct {
  midi_note_event_t note;
  bool enabled;
  bool set;
  unsigned long setTime; //millis
} note_off_t;


typedef struct {
  button_func_params_t button;
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



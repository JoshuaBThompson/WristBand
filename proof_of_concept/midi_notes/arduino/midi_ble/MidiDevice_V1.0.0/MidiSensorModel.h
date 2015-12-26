/*
 * Defines structures used by MidiSensor to store params used for calculations and structs for measurements that can be read
 */

#ifndef MidiSensorModel_h
#define MidiSensorModel_h

/*********MidiSensor Struct
 * Defines structure of MidiSensor object 
 * Note On events
 * Note Off events
 * Generic midi events
 * Button
 * sources and mode of note event values
***********/


//source of motion data for a midi event
typedef enum {ACCEL_X, ACCEL_Y, ACCEL_Z, GYRO_X, GYRO_Y, GYRO_Z} sources_t;
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
} note_off_t;


typedef struct {
  button_func_params_t button;
  note_on_t noteOn;
  note_off_t noteOff;
  midi_event_t event;
} model_t;

#endif //MidiSensorModel_h

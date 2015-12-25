/*
 * Defines structures used by MidiSensor to store params used for calculations and structs for measurements that can be read
 */

#ifndef MidiSensorModel_h
#define MidiSensorModel_h

//source of motion data for a midi event
typedef enum {ACCEL_X, ACCEL_Y, ACCEL_Z, GYRO_X, GYRO_Y, GYRO_Z} sources_t;
typedef enum {ROTATION, SINGLE} note_modes_t;
typedef enum {EN_CC, NOTE, PAUSE, START} button_func_sources_t;


//-----------Define params struct
//note is just a type of midi message but we always use it so it has its own struct
typedef struct {
  char number;
  char velocity;
  char channel;
  sources_t source;
  note_modes_t mode;
} midi_note_params_t;

//midi message can be a note, a continuous control, a polyphonic aftertouch, program change event...etc
//user can change the type of message to whatever they want.
//The sensor will send out this message periodically. The message is tied to specified sensor data (gyor or accel or rotation angle)
typedef struct {
  char statusByte; //ex: cc channel 1 = 0xB0
  char dataByte1;  //ex: cc volume control = 0x07
  char dataByte2;  //ex: cc volume value of 127 = 0x7f
  sources_t source;
} midi_message_params_t;

//motion filter params
typedef struct {
  int minDiff;
  int minSum;
  int minFalling;
  int catchFalling;
  int maxSamples;
} motion_filter_params_t;

//button function params
typedef struct {
  button_func_sources_t source;
} button_func_params_t;

 
typedef struct {
  midi_note_params_t note;
  midi_message_params_t message;
  motion_filter_params_t filter;
  button_func_params_t button;
} params_t;

//-------------Define measurements struct
typedef struct {
  int ax;
  int ay;
  int az;
} accel_measurements_t;

typedef struct {
  int wx;
  int wy;
  int wz;
} gyro_measurements_t;

typedef struct {
  int angle;
} rotation_measurements_t;

typedef struct {
  accel_measurements_t accel;
  gyro_measurements_t gyro;
  rotation_measurements_t rotation;
} measurements_t;

//----------Define midi events struct

//note on / off struct that uses note ptr
typedef struct {
  midi_note_params_t note;
} note_on_t;

typedef struct {
  midi_note_params_t note;
} note_off_t;

typedef struct {
  midi_message_params_t msg;
} msg_t;


typedef struct {
  note_off_t note_off;
  note_on_t note_on;
  msg_t msg;
} midi_events_t;

//------------Define model struct
typedef struct {
  midi_events_t midi_events;
  measurements_t measurements;
  params_t params;
} sensor_model_t;

#endif //MidiSensorModel_h

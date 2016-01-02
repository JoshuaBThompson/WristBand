/*
MidiSensor.cpp
Author: jbthompson.eng@gmail.com
Date Created: 12/22/2015
Desc: Main object that is responsible for filtering motion data to produce data relating to midi events
*/


#include <inttypes.h>
#include <stdint.h>

/*
 * Constructor
*/
MidiSensor::MidiSensor(void) {
    motionFilter = MotionFilter();
    model.timeInterval = TimeInterval; //35 ms
}


/*
 * Reset MidiDevice attributes to defaults
*/
void MidiSensor::reset(void){
  //todo:
}

/*
 * Init MidiDevice by 
*/
void MidiSensor::init(void){
   //todo: init model?
   //reset variables
    reset();
}


/*
 * Reset Note params / on / off
 */

void MidiSensor::resetNoteParams(void){

  //note params
    model.noteParams.note1Number = NOTE1_NUMBER;
    model.noteParams.note2Number = NOTE2_NUMBER;
    model.noteParams.channel = NOTE_CHANNEL;
    model.noteParams.velocity = NOTE_VELOCITY;
    model.noteParams.mode = ROTATION;
    model.noteParams.source = ACCEL_X;

    //note on / off
    model.noteOn.note.statusByte = NOTE_ON_BYTE + NOTE_CHANNEL;
    model.noteOn.note.dataByte1 = NOTE1_NUMBER;
    model.noteOn.note.dataByte2 = NOTE_VELOCITY;
    model.noteOn.enabled = false;

    model.noteOff.note.statusByte = NOTE_OFF_BYTE + NOTE_CHANNEL;
    model.noteOff.note.dataByte1 = NOTE1_NUMBER;
    model.noteOff.note.dataByte2 = 0; //velocity not really necessary...
    model.noteOff.enabled = false;
    model.noteOff.set = false;
    mode.noteOff.setTime = 0;
  
}

/*
 * Reset generic event params
 */

void MidiSensor::resetEventParams(void){
  //generic event params
    model.eventParams.source = ACCEL_Z;
    model.eventParams.channel = EVENT_CHANNEL;

    //generic event
    model.event.statusByte = DEFAULT_STATUS_BYTE;
    model.event.dataByte1 = DEFAULT_EVENT_DATA_BYTE1;
    model.event.dataByte2 = DEFAULT_EVENT_DATA_BYTE2;
}

/*
 * Reset / init model vars
 */

void MidiSensor::reset(void){
  model.timeInterval = TimeInterval; //35 ms
  resetNoteParams();
  resetEventParams();
}

/*
 * Get Note On state / updat model
 */
void MidiSensor::updateNoteOnState(void){
  model.noteOn.enabled = motionFilter.model.beat;
  if(model.noteOn.enabled){
    if(model.noteParams.mode == ROTATION){
      if(motionFilter.rotationFilter.rotationNumber == motionFilter.rotationFilter.firstRotation){
        model.noteOn.note.dataByte1 = model.noteParams.noteNumber1;
      }
      else{
        model.noteOn.note.dataByte1 = model.noteParams.noteNumber2;
      }
    }
    else{
      model.noteOn.note.dataByte1 = model.noteParams.noteNumber1;
    }
    updateNoteOnQueue();
  }
  return ;
}

/*
 * Get event state / update model
 */
void MidiSensor::updateEventState(void){
  model.event.dataByte2 = motionFilter.imuFilter.model.data.dataArray[model.event.source]; //choose accel or gyro or mag  ...(x, y, z)
  return ;
}


/*
 * Update Note Off state / update model
 */

void MidiSensor::updateNoteOffState(void){
  if(model.noteOff.set && model.noteOn.enabled){
    model.noteOff.enabled = true;
    updateNoteOffQueue(); //put noteoff on queue then reset set and enabled vars
    //since note enabled the set noteOff again and record time
    model.noteOff.set = true;
    model.noteOff.setTime = model.currentTime;
  }

  else if (model.noteOn.enabled){
    //new note detected, so set noteOff and record time and set noteOff note value to prev note value
    model.noteOff.set = true;
    model.noteOff.setTime = model.currentTime;
    model.noteOff.note.dataByte1 = model.noteOn.note.dataByte1; //set not off value to current note on value
  }

  int timeDiff = model.currentTime - model.noteOff.setTime;
  else if (model.noteOff.set && timeDiff >= model.noteOff.maxTimeDelay){
    model.noteOff.enabled = true;
    updateNoteOffQueue(); //put noteoff on queue then reset set and enabled vars
  }
  
}


/*
 * Filter beat and motion data and update model state variables (not on, off, cc ...etc)
 */
void MidiSensor::updateState(void){
  model.currentTime = millis();
  if(model.currentTime - model.prevTime < model.intervalTime)
  {
      return;
  }
  else{
      model.prevTime = model.currentTime;
  }
  
  motionFilter.updateState();
    
  //update model
  updateNoteOnState();
  updateNoteOffState();
  updateEventState();
}

/*
 * Update midi note mode source 
 */

void MidiSensor::updateMidiNoteMode(char modeNumber){
  note_modes_t number = (note_modes_t)modeNumber;
  switch(number){
    case ROTATION:
      model.noteParams.mode = number;
    break;
    case SINGLE:
      model.noteParams.mode = number;
    break;
    default:
      //no nothing, since mode number is not a valid option
    break;
  }
}

/*
 * Update midi generic event motion source
 */

void MidiSensor::updateMidiEventSource(char sourceNumber){
  sources_t source = (sources_t)sourceNumber:
  switch(source){
    case ACCEL_X:
      model.eventParams.source = source;
    break;
    case ACCEL_Y:
      model.eventParams.source = source;
    break;
    case ACCEL_Z:
      model.eventParams.source = source;
    break;
    case GYRO_X:
      model.eventParams.source = source;
    break;
    case GYRO_Y:
      model.eventParams.source = source;
    break;
    case GYRO_Z:
      model.eventParams.source = source;
    break;
    case MAG_X:
      model.eventParams.source = source;
    break;
    case MAG_Y:
      model.eventParams.source = source;
    break;
    case MAG_Z:
      model.eventParams.source = source;
    break;
    default:
      //do nothing since not a valid option
    break;
    
  }
  
}

/*
 * Update midi note motion source
 */

void MidiSensor::updateMidiNoteSource(char sourceNumber){
  sources_t source = (sources_t)sourceNumber:
  switch(source){
    case ACCEL_X:
      model.noteParams.source = source;
    break;
    case ACCEL_Y:
      model.noteParams.source = source;
    break;
    case ACCEL_Z:
      model.noteParams.source = source;
    break;
    case GYRO_X:
      model.noteParams.source = source;
    break;
    case GYRO_Y:
      model.noteParams.source = source;
    break;
    case GYRO_Z:
      model.noteParams.source = source;
    break;
    case MAG_X:
      model.noteParams.source = source;
    break;
    case MAG_Y:
      model.noteParams.source = source;
    break;
    case MAG_Z:
      model.noteParams.source = source;
    break;
    default:
      //do nothing since not a valid option
    break;
    
  }
  
}

/*
 * Update note on pitch and vel based on mode and motion source
 */

void MidiSensor::updateNoteOnNumber(void){
  
}


/*
 * Update note off pitch and vel based on mode and motion source
 */

void MidiSensor::updateNoteOffNumber(void){
  
}

/*
 * Update the note on/off number for option 1 (assigned to any beat if not using rotation  mode, or rotation angle 1 if using rotation mode)
 */

void MidiSensor::updateNote1Number(byte noteNumber){
   model.noteParams.noteNumber1 = noteNumber;;
}

/*
 * Update the note on/off number for option 2 (assigned to any beat if not using rotation  mode, or rotation angle 1 if using rotation mode)
 */

void MidiSensor::updateNote2Number(byte noteNumber){
  model.noteParams.noteNumber2 = noteNumber;
}







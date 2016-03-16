/*
 MidiSensor.cpp
 Author: jbthompson.eng@gmail.com
 Date Created: 12/22/2015
 Desc: Main object that is responsible for filtering motion data to produce data relating to midi events
 */


#include <inttypes.h>
#include <stdint.h>
#include "MidiSensor.h"

/*
 * Constructor
 */
MidiSensor::MidiSensor(void) {
    model.intervalTime = IntervalTime; //35 ms
}


/*
 * Reset / init model vars
 */

void MidiSensor::reset(void){
    model.intervalTime = IntervalTime; //35 ms
    resetNoteParams();
    resetEventParams();
    resetBlankEvent();
}

/*
 * Init MidiDevice by
 */
void MidiSensor::init(void){
    //todo: init model?
    //reset variables
    reset();
    motionFilter.init();
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
    model.noteParams.source = ACCEL;
    model.noteParams.axis = X;
    
    //note on / off
    model.noteOn.note.valid = true;
    model.noteOn.note.statusByte = NOTE_ON_BYTE + NOTE_CHANNEL;
    model.noteOn.note.dataByte1 = NOTE1_NUMBER;
    model.noteOn.note.dataByte2 = NOTE_VELOCITY;
    model.noteOn.enabled = false;
    
    model.noteOff.note.valid = true;
    model.noteOff.note.statusByte = NOTE_OFF_BYTE + NOTE_CHANNEL;
    model.noteOff.note.dataByte1 = NOTE1_NUMBER;
    model.noteOff.note.dataByte2 = 0; //velocity not really necessary...
    model.noteOff.enabled = false;
    model.noteOff.set = false;
    model.noteOff.setTime = 0;
    model.noteOff.maxTimeDelay = NoteOffMaxTimeDelay; //100 ms
    
}

/*
 * Reset generic event params
 */

void MidiSensor::resetEventParams(void){
    //generic event params
    model.eventParams.source = ACCEL;
    model.eventParams.axis = Z;
    model.eventParams.channel = DEFAULT_EVENT_CHANNEL;
    
    //generic event
    model.event.valid = true;
    model.event.statusByte = DEFAULT_EVENT_STATUS_BYTE;
    model.event.dataByte1 = DEFAULT_EVENT_DATA_BYTE1;
    model.event.dataByte2 = DEFAULT_EVENT_DATA_BYTE2;
}

/*
 * Reset Null / blank event - readEvent returns null event if nothing in queue
 */

void MidiSensor::resetBlankEvent(void){
    model.blankEvent.valid = false;
    model.blankEvent.statusByte = 0;
    model.blankEvent.dataByte1 = 0;
    model.blankEvent.dataByte2 = 0;
}


/*
 * Get Note On state / updat model
 */
void MidiSensor::updateNoteOnState(void){
    model.noteOn.enabled = motionFilter.model.beat;
    if(model.noteOn.enabled){
        updateNoteOnNumber();
        updateNoteOnQueue();
    }
    return ;
}

/*
 * Get event state / update model
 */
void MidiSensor::updateEventState(void){
    char sourceIndex = (char)model.eventParams.source;
    char axisIndex = (char)model.eventParams.axis;
    char imuValueIndex = sourceIndex*(3) + axisIndex;
    
    model.event.dataByte2 = motionFilter.imuFilter.model.rawData.dataArray[imuValueIndex]; //choose accel or gyro or mag  ...(x, y, z)
}


/*
 * Update Note Off state / update model
 */

void MidiSensor::updateNoteOffState(void){
    unsigned long timeDiff = model.currentTime - model.noteOff.setTime;
    
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
        updateNoteOffNumber();
    }
    
    else if (model.noteOff.set && timeDiff >= model.noteOff.maxTimeDelay){
        model.noteOff.enabled = true;
        updateNoteOffQueue(); //put noteoff on queue then reset set and enabled vars
        model.noteOff.enabled = false;
        model.noteOff.set = false;
    }
    
}


/*
 * Filter beat and motion data and update model state variables (not on, off, cc ...etc)
 */
void MidiSensor::updateState(int x, int y, int z){
    model.currentTime = millis();
    if(model.currentTime - model.prevTime < model.intervalTime)
    {
        return;
    }
    else{
        model.prevTime = model.currentTime;
    }
    
    
    motionFilter.updateState(x, y, z);
    
    //update model
    updateNoteOnState();
    updateNoteOffState();
    updateEventState();
}

/*
 * Update the note number of the note on event based on mode
 */

void MidiSensor::updateNoteOnNumber(void){
    if(model.noteParams.mode == ROTATION){
        
        model.noteOn.note.dataByte1 = model.noteParams.note2Number;
    }
    else{
        model.noteOn.note.dataByte1 = model.noteParams.note1Number;
    }
}

/*
 * Update note off pitch and vel based on mode and motion source
 */

void MidiSensor::updateNoteOffNumber(void){
    model.noteOff.note.dataByte1 = model.noteOn.note.dataByte1; //set not off value to current note on value
}

/*
 * Put note off data into queue so that other objects can access the midi sensor data on the fly
 */
void MidiSensor::updateNoteOffQueue(void){
    midiEventQueue.push(model.noteOff.note);
}

/*
 * Put note on data into queue so that other objects can access the midi sensor data on the fly
 */
void MidiSensor::updateNoteOnQueue(void){
    midiEventQueue.push(model.noteOn.note);
}

/*
 * Set midi note mode source
 */

void MidiSensor::setMidiNoteMode(char modeNumber){
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
 * Set midi generic event motion axis
 */

void MidiSensor::setMidiEventAxis(char axisNumber){
    axis_t axis = (axis_t)axisNumber;
    switch(axis){
        case X:
            model.eventParams.axis = axis;
            break;
        case Y:
            model.eventParams.axis = axis;
            break;
        case Z:
            model.eventParams.axis = axis;
            break;
        default:
            //do nothing since not a valid option
            break;
    }
}

/*
 * Set midi generic event motion source
 */

void MidiSensor::setMidiEventSource(char sourceNumber){
    sources_t source = (sources_t)sourceNumber;
    switch(source){
        case ACCEL:
            model.eventParams.source = source;
            break;
        case GYRO:
            model.eventParams.source = source;
            break;
        case MAG:
            model.eventParams.source = source;
            break;
        default:
            //do nothing since not a valid option
            break;
            
    }
    
}

/*
 * Set midi note motion axis / beat filter axis
 */

void MidiSensor::setMidiNoteAxis(char axisNumber){
    axis_t axis = (axis_t)axisNumber;
    switch(axis){
        case X:
            model.noteParams.axis = axis;
            motionFilter.beatFilter.setAxisSource(axisNumber);
            break;
        case Y:
            model.noteParams.axis = axis;
            motionFilter.beatFilter.setAxisSource(axisNumber);
            break;
        case Z:
            model.noteParams.axis = axis;
            motionFilter.beatFilter.setAxisSource(axisNumber);
            break;
        default:
            //do nothing since not a valid option
            break;
    }
}

/*
 * Set midi note motion source / beat filter source
 */

void MidiSensor::setMidiNoteSource(char sourceNumber){
    sources_t source = (sources_t)sourceNumber;
    switch(source){
        case ACCEL:
            model.noteParams.source = source;
            motionFilter.beatFilter.setMotionSource(sourceNumber);
            break;
        case GYRO:
            model.noteParams.source = source;
            motionFilter.beatFilter.setMotionSource(sourceNumber);
            break;
        case MAG:
            model.noteParams.source = source;
            motionFilter.beatFilter.setMotionSource(sourceNumber);
            break;
        default:
            //do nothing since not a valid option
            break;
            
    }
    
}


/*
 * Set the note on/off number for option 1 (assigned to any beat if not using rotation  mode, or rotation angle 1 if using rotation mode)
 */

void MidiSensor::setNote1Number(unsigned char noteNumber){
    model.noteParams.note1Number = noteNumber;;
}

/*
 * Set the note on/off number for option 2 (assigned to any beat if not using rotation  mode, or rotation angle 1 if using rotation mode)
 */

void MidiSensor::setNote2Number(unsigned char noteNumber){
    model.noteParams.note2Number = noteNumber;
    
}

/*
 * Set Note Channel
 */
void MidiSensor::setNoteChannel(unsigned char channel){
    model.noteParams.channel = channel;
    //update Note on/off
    if(channel <= 15){
        model.noteOn.note.statusByte = NOTE_ON_BYTE + channel; //note on byte at ch1 + ch num (ex: 0x90 is note on ch1, 0x90 + 0x01 = 0x91 is note on ch2...etc)
        model.noteOff.note.statusByte = NOTE_OFF_BYTE + channel;
    }
    
}

/*
 * Set Note Velocity
 */
void MidiSensor::setNoteVelocity(unsigned char velocity){
    model.noteParams.velocity = velocity;
    //update Note on/off
    model.noteOn.note.dataByte2 = velocity; //note velocity 0 (0x00) - 127 (0x7F)
    //don't need to update noteOff, since velocity of note off has no effect on the midi output
}

/*
 * Set generic event channel (ex cc ch1)
 */
void MidiSensor::setEventChannel(unsigned char channel){
    model.eventParams.channel = channel;
    if(channel <= 15){
        model.event.statusByte &= 0xF0; //clear first 4 bits of the existing channel number
        model.event.statusByte |= channel; //now add new channel number to end of status byte
    }
}

/*
 * Set generic event type (ex change from cc to pitch modulation)
 */

void MidiSensor::setEventType(unsigned char eventType){
    //ex: cc event type 4 bits is 0xB0 (for ch1)
    //even type byte must be between 0xF0 and 0x80
    if(!(eventType & 0x0F) && eventType>=MIDI_MESSAGE_LIST_FIRST){
        model.event.statusByte &= 0x0F; //get rid of existing status 4 bits but keep channel bits
        model.event.statusByte |= eventType; //add event type bits
    }
}



/*
 * Read midi event from queue
 */

midi_event_t MidiSensor::readEvent(void){
    midi_event_t event;
    if(!midiEventQueue.empty()){
        event = midiEventQueue.front(); //get oldest data
        midiEventQueue.pop(); //remove it from queue
    }
    else{
        //if queue empty return blank event that has valid param = false
        event = model.blankEvent;
    }
    return event;
}







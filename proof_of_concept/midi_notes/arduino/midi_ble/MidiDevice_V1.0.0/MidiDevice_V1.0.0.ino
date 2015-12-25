#include <SPI.h>
#include <EEPROM.h>
#include <Wire.h>
#include <I2Cdev.h>

MidiDevice midiDevice = MidiDevice();


/* Define how assert should function in the BLE library */
void __ble_assert(const char *file, uint16_t line)
{
  delay(5000);
  Serial.print("ERROR ");
  Serial.print(file);
  Serial.print(": ");
  Serial.print(line);
  Serial.print("\n");
  while(1);
}

void setup(void)
{
  Serial.begin(115200);
  //Wait until the serial port is available (useful only for the Leonardo)
  //As the Leonardo board is not reseted every time you open the Serial Monitor
  #if defined (__AVR_ATmega32U4__)
    delay(2000);
    while(!Serial)
    {}
    delay(5000);  //5 seconds delay for enabling to see the start up comments on the serial board
  #elif defined(__PIC32MX__)
    delay(1000);
  #endif

  //Init midi device
  midiDevice.init();
  
}


void loop() {
  midiDevice.handleBleEvents(); //check bluetooth communication buffer to see if any messages from user, handle cmds or errors
  midiDevice.updateState(); //update values from the accelerometer / gyro, note #, rotation angle, channel #, mode, button output (cc...etc)
  midiDevice.sendState(); //if note valid sends midi note, if button pressed send midi message (varies), send sensor data?
}





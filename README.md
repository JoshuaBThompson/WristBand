# WristBand
## Gesture MIDI Controller
### Proof of Concept
#### Apps
- iOS and OSX apps
- Uses AudioKit library to produce synthesized sounds
- Receive commands from midi device over bluetooth low energy and produces sound based on midi notes (OSX)
- Analyzes user motion to produce a beat and uses AudioKit to produce synth drum sounds (iOS)
- Both iOS and OSX apps are in development; some are usable some are not

#### Arduino
- C++ code to run on an arduino leonardo attached to MP6050 (gyro + accel) and nordic nrf8001 bluetooth LE chip
- Analyzes user motion to produce a beat / midi note and sends to iphone or mac over bluetooth (midi over ble)

#### Micropython
- Proof of concept code running on micropython board with accelerometer
- Would generate some beats based on acceleration data and generate midi notes to send over USB

#### Pygraph
- Can be used to analyze acceleration, gyro or other data on a graph
- Send over USB using arduino

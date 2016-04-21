//
//  ViewController.h
//  MidiDevice
//
//  Created by sofiebio on 11/29/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import "Instrument.h"

@interface ViewController : NSViewController <NSApplicationDelegate,CBCentralManagerDelegate, CBPeripheralDelegate>
{
    //midi bluetooth low energy
    NSString * deviceName;
    NSString * manufactureName;
    NSString * tempType;
    NSString * tempString;
    NSString * mesurementType;
    NSString * timeStampString;
    NSString * connectStatus;
    
    CBCentralManager *manager;
    CBPeripheral *testPeripheral;
    CBCharacteristic * midiData;
    CBCharacteristic * beanData;
    
    NSMutableArray *midiDevices;
    NSArrayController *arrayController;
    BOOL autoConnect;
    BOOL audioMidiSetupEn;
}
//midi bluetooth low energy
@property (copy) NSString* deviceName;
@property (copy) NSString * manufactureName;
@property (copy) NSString* tempType;
@property (copy) NSString* tempString;
@property (copy) NSString* timeStampString;
@property (copy) NSString * connectStatus;
@property (copy) NSString * mesurementType;
@property (retain) CBCharacteristic * midiData;
@property (retain) NSMutableArray *midiDevices;

//light blue bean
@property (retain) CBCharacteristic * beanData;

@property Instrument *instrument;

//audiokit

- (IBAction)play:(NSButton *)sender;
- (IBAction)record:(NSButton *)sender;
- (IBAction)stop:(NSButton *)sender;

//midi ble, note change..etc
- (void) updateParams;
- (IBAction)changeNote1:(NSButton *)sender;
- (IBAction)changeNote2:(NSButton *)sender;
- (IBAction)connect:(NSButton *)sender;
- (IBAction)changeCCMode:(NSButton *)sender;
- (IBAction)changeChannel:(NSButton *)sender;
- (IBAction)changeTempo:(NSButton *)sender;
- (IBAction)changeMeasures:(NSButton *)sender;
- (IBAction)changeTimeSignature:(NSButton *)sender;
- (IBAction)clearTrack:(NSButton *)sender;



@property (weak) IBOutlet NSButton *connectButton;

@property (weak) IBOutlet NSTextField *note1Value;
@property (weak) IBOutlet NSTextField *note2Value;
@property (weak) IBOutlet NSTextField *ccModeValue;
@property (weak) IBOutlet NSTextField *channelNumber;
@property (weak) IBOutlet NSTextField *tempoValue;
@property (weak) IBOutlet NSTextField *measuresValue;
@property (weak) IBOutlet NSTextField *timeSignatureValue;
@property (weak) IBOutlet NSTextField *measureCounter;
@property (weak) IBOutlet NSTextField *beatCounter;
@property (weak) IBOutlet NSTextField *totalDuration;

- (void) startScan;
- (void) startReceivingMidi;
- (BOOL) isLECapableHardware;


@end

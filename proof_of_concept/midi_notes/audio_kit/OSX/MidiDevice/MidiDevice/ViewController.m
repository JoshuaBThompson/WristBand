//
//  ViewController.m
//  MidiDevice
//
//  Created by sofiebio on 11/29/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "ViewController.h"

// STEP 1 : Import AudioKit's suite of classes
#import "AKFoundation.h"

@implementation ViewController {
    // STEP 2 : Set up an instance variable for the instrument
    NSString * midiServiceUUID;
    NSString * midiIOUUID;
    unsigned char data1[7];
    unsigned char data2[7];
}

@synthesize deviceName;
@synthesize manufactureName;
@synthesize tempType;
@synthesize tempString;
@synthesize timeStampString;
@synthesize connectStatus;
@synthesize mesurementType;
@synthesize midiData;
@synthesize midiDevices;

- (void)viewDidLoad {
    [super viewDidLoad];
    midiServiceUUID = @"03B80E5A-EDE8-4B33-A751-6CE34EC4C700";
    midiIOUUID = @"7772E5DB-3868-4112-A1A9-F2669D106BF3";
    data1[0]=0x0A; data1[1] = 0x00; data1[2] = 0x70;
    data2[0]=0x0A; data2[1] = 0x01; data2[2] = 0x30;
    
    //instruments
    AKTambourineInstrument * tambourine = [[AKTambourineInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:tambourine];
    
    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:tambourine.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];
    [tambourine play];
    
    
    self.instrument = [[Instrument alloc] initWithInstrumet:tambourine];
    [AKOrchestra addInstrument:self.instrument];
    [self.instrument startMidiInputHandler];
    [self.instrument startListeningOnAllMidiChannels];
    [self.instrument play];
    
    //load cb manager
    autoConnect = TRUE;  /* uncomment this line if you want to automatically connect to previosly known peripheral */
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}


//bluetooth methods
#pragma mark - Start/Stop Scan methods
/*
 Request CBCentralManager to scan for health thermometer peripherals using service UUID 0x1809
 */
- (void)startScan
{
    
    NSArray* connectedDevices = [manager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:midiServiceUUID]]];
    NSLog(@"Found %lu connected devices", (unsigned long)[connectedDevices count]);
    if(connectedDevices.count > 0){
    testPeripheral = [connectedDevices objectAtIndex:0];
    [manager connectPeripheral:testPeripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    [manager connectPeripheral:testPeripheral options:nil];
    }
    else{
        NSLog(@"No valid midi bluetooth device found!");
    }
    
}

/*
 Start bluetooth characteristic notify to receive midi data from device
 */
- (void)startReceivingMidi{
#pragma mark - Start/Stop notification/indication

        if( self.midiData)
        {
            /* Set indication on temperature measurement characteristic */
            [testPeripheral setNotifyValue:true forCharacteristic:self.midiData];
        }
}

#pragma mark - LE Capable Platform/Hardware check
/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    return FALSE;
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect to peripheral: %@", peripheral);
    NSLog(@"CB Central Manager State: %ld", (long)[manager state]);
    NSLog(@"Number of services %lul", (unsigned long)[[peripheral services] count]);
    
    self.connectStatus = @"Connected";
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did Disconnect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);
    self.connectStatus = @"Not Connected";
    self.deviceName = @"";
    self.timeStampString = @"";
    self.tempType = @"";
    self.tempString = @"";
    self.mesurementType = @"";
    self.manufactureName = @"";
    NSLog(@"Disconnected from peripheral");
    if( testPeripheral )
    {
        [testPeripheral setDelegate:nil];
        testPeripheral = nil;
    }
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);
    if( testPeripheral )
    {
        [testPeripheral setDelegate:nil];
        testPeripheral = nil;
    }
}

#pragma mark - CBManagerDelegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
}

#pragma mark - CBPeripheralDelegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Discovering services for peripheral!! %@", peripheral);
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"Again! Number of services %lul", (unsigned long)[[peripheral services] count]);
    for (CBService * service in peripheral.services)
    {
        NSLog(@"Service found with UUID: %@", service.UUID);
        
        if([service.UUID isEqual:[CBUUID UUIDWithString: midiServiceUUID]])
        {
            /* Midi BLE Service */
            [testPeripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString: midiIOUUID], nil] forService:service];
        }
        else if([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        {
            /* Device Information Service - discover manufacture name characteristic */
            [testPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A29"]] forService:service];
        }
        else if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
        {
            /* GAP (Generic Access Profile) - discover device name characteristic */
            [testPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]  forService:service];
        }
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    if([service.UUID isEqual:[CBUUID UUIDWithString: midiServiceUUID]])
    {
        for (CBCharacteristic * characteristic in service.characteristics)
        {
            /* Set indication on temperature measurement */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString: midiIOUUID]])
            {
                self.midiData = characteristic;
                NSLog(@"Found a MIDI IO Characteristic !! %@", self.midiData);
            }
            
        }
        
        [self startReceivingMidi];
    }
    
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        for (CBCharacteristic * characteristic in service.characteristics)
        {
            /* Read manufacturer name */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
            {
                [testPeripheral readValueForCharacteristic:characteristic];
                NSLog(@"Found a Device Manufacturer Name Characteristic - Read manufacturer name");
            }
        }
    }
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            /* Read device name */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
            {
                [testPeripheral readValueForCharacteristic:characteristic];
                NSLog(@"Found a Device Name Characteristic - Read device name");
            }
        }
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    /* Value for device name received */
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:midiIOUUID]])
    {
        NSLog(@"Midi Response= %@", characteristic);
        NSData * updatedValue = characteristic.value;
        NSLog(@"MIDI Response Data = %@", updatedValue);
    }
    
    /* Value for device name received */
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
    {
        self.deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Device Name = %@", self.deviceName);
    }
    
    /* Value for manufacturer name received */
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
    {
        self.manufactureName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Manufacturer Name = %@", self.manufactureName);
    }
}

/*
 Invoked upon completion of a -[writeValue:forCharacteristic:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error writing value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
}

/*
 Invoked upon completion of a -[setNotifyValue:forCharacteristic:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating notification state for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    NSLog(@"Updated notification state for characteristic %@ (newState:%@)", characteristic.UUID, [characteristic isNotifying] ? @"Notifying" : @"Not Notifying");
    
    if( [characteristic.UUID isEqual:[CBUUID UUIDWithString: midiIOUUID]])
    {
        
    }     
}

/*
 Disconnect peripheral when application terminate
 */
- (void) applicationWillTerminate:(NSNotification *)notification
{
    if(testPeripheral)
    {
        [manager cancelPeripheralConnection:testPeripheral];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)play:(NSButton *)sender {
    NSLog(@"Playing sound!");
    [self.instrument playRecord];
}

- (IBAction)record:(NSButton *)sender {
    NSLog(@"Recording");
    [self.instrument recordNotes];
}

- (IBAction)changeNote1:(NSButton *)sender {
    
    if(testPeripheral){
        NSLog(@"Change note 1");
        int value = [self.note1Value intValue];
        data1[2] = value;
        NSData *data = [NSData dataWithBytes: data1 length: 4];
        
        if([data bytes]){
            NSLog(@"changing to note number 1");
        [testPeripheral writeValue:data forCharacteristic:self.midiData type:CBCharacteristicWriteWithoutResponse];
        }
        
    }
}

- (IBAction)changeNote2:(NSButton *)sender {
    if(testPeripheral){
        NSLog(@"Change note 2");
        int value = [self.note2Value intValue];
        data2[2] = value;
        NSData *data = [NSData dataWithBytes: data2 length: 4];
        
        if([data bytes]){
            NSLog(@"changing to note number 2");
            [testPeripheral writeValue:data forCharacteristic:self.midiData type:CBCharacteristicWriteWithoutResponse];
        }
        
    }
}

- (IBAction)connect:(NSButton *)sender {
    NSLog(@"Connecting to bluetooth device");
    if( autoConnect )
    {
        [self startScan];
    }
}
@end

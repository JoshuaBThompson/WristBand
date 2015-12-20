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
    unsigned char note1Data[7];
    unsigned char note2Data[7];
    unsigned char ccModeData[7];
    unsigned char channelChangeData[7];
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
    note1Data[0]=0x0A; note1Data[1] = 0x00; note1Data[2] = 0x70;
    note2Data[0]=0x0A; note2Data[1] = 0x01; note2Data[2] = 0x30;
    ccModeData[0]=0x0C; ccModeData[1] = 0x00; ccModeData[2] = 0x00;
    channelChangeData[0]=0x0D; channelChangeData[1] = 0x00; channelChangeData[2] = 0x00;
    
    self.midiDevices = [NSMutableArray array];
    
    //instruments
    AKTambourineInstrument * tambourine = [[AKTambourineInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:tambourine];
    
    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:tambourine.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];
    [tambourine play];
    
    
    self.instrument = [[Instrument alloc] initWithInstrumet:tambourine];
    //register as an observer of instrument.record value
    [self.instrument.track.clickTrack addObserver:self forKeyPath:@"currentMeasureCount" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    
    [self.instrument.track.clickTrack addObserver:self forKeyPath:@"currentBeatInMeasure" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    
    [AKOrchestra addInstrument:self.instrument];
    [self.instrument play];
    
    //load cb manager
    autoConnect = TRUE;  /* uncomment this line if you want to automatically connect to previosly known peripheral */
    audioMidiSetupEn = FALSE;
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self updateParams];
}

- (void) dealloc
{
    [self stopScan];
    
    [testPeripheral setDelegate:nil];
    
    
    
}

/*
 Request CBCentralManager to stop scanning for health thermometer peripherals
 */
- (void)stopScan
{
    [manager stopScan];
}


//bluetooth methods
#pragma mark - Start/Stop Scan methods
/*
 Request CBCentralManager to scan for health thermometer peripherals using service UUID 0x1809
 */
- (void)startScan
{
    
    //check if already connected
    if(testPeripheral){
        NSLog(@"Already connected to peripheral");
        return;
    }
    
    NSArray* connectedDevices = [manager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:midiServiceUUID]]];
    NSLog(@"Found %lu connected devices", (unsigned long)[connectedDevices count]);
    if(connectedDevices.count > 0){
        audioMidiSetupEn = TRUE;
    testPeripheral = [connectedDevices objectAtIndex:0];
    [manager connectPeripheral:testPeripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    [manager connectPeripheral:testPeripheral options:nil];
        
    [self.instrument startMidiInputHandler];
    [self.instrument startListeningOnAllMidiChannels];
        
    }
    else{
        NSLog(@"No connected midi bluetooth device found!");
        NSLog(@"Scanning for unconnected devices");
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        audioMidiSetupEn = FALSE;
        [manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:midiServiceUUID]] options:options];
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
    [self.connectButton setTitle:@"Connected!"];
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

/*
 Invoked when the central discovers thermometer peripheral while scanning.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData);
    
    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"midiDevices"];
    if( ![self.midiDevices containsObject:peripheral] )
        [peripherals addObject:peripheral];
    
    /* Retreive already known devices */
    if(autoConnect)
    {
        [manager retrievePeripherals:[NSArray arrayWithObject:(id)peripheral.UUID]];
    }
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %lu - %@", [peripherals count], peripherals);
    
    [self stopScan];
    
    /* If there are any known devices, automatically connect to it.*/
    if([peripherals count] >=1)
    {

        testPeripheral = [peripherals objectAtIndex:0];
        [manager connectPeripheral:testPeripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
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
        if(!audioMidiSetupEn){
            [self.instrument midiNoteOn];
        }
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

- (IBAction)stop:(NSButton *)sender {
    NSLog(@"Stop recording or playing!");
    [self.instrument stopRecord];
}

- (IBAction)changeNote1:(NSButton *)sender {
    
    if(testPeripheral){
        NSLog(@"Change note 1");
        int value = [self.note1Value intValue];
        note1Data[2] = value;
        NSData *data = [NSData dataWithBytes: note1Data length: 4];
        
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
        note2Data[2] = value;
        NSData *data = [NSData dataWithBytes: note2Data length: 4];
        
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

- (IBAction)changeCCMode:(NSButton *)sender {
    if(testPeripheral){
        
        int value = [self.ccModeValue intValue];
        ccModeData[1] = value;
        NSData *data = [NSData dataWithBytes: ccModeData length: 4];
        
        if([data bytes]){
            NSLog(@"Change cc mode value %@", data);
            [testPeripheral writeValue:data forCharacteristic:self.midiData type:CBCharacteristicWriteWithoutResponse];
        }
        
    }
}

- (IBAction)changeChannel:(NSButton *)sender {
    
    if(testPeripheral){
        
        int value = [self.channelNumber intValue];
        channelChangeData[1] = value;
        NSData *data = [NSData dataWithBytes: channelChangeData length: 4];
        
        if([data bytes]){
            NSLog(@"Changing channel number %@", data);
            [testPeripheral writeValue:data forCharacteristic:self.midiData type:CBCharacteristicWriteWithoutResponse];
        }
        
    }
}

- (IBAction)changeTempo:(NSButton *)sender {
    NSLog(@"Changing tempo");
    float newTempo = self.tempoValue.floatValue;
    [self.instrument updateTempo:newTempo];
    [self updateParams];
    
}

- (IBAction)changeMeasures:(NSButton *)sender {
    NSLog(@"Changing measures");
    int measures = self.measuresValue.intValue;
    [self.instrument updateMeasures:measures];
    [self updateParams];
    
}

- (IBAction)changeTimeSignature:(NSButton *)sender {
    NSString * timeSignatureStr = self.timeSignatureValue.stringValue;
    NSArray * signatureParams = [timeSignatureStr componentsSeparatedByString:@"/"];
    if(signatureParams.count==2){
        NSString * beatsPerMeasure = signatureParams[0];
        NSString * noteSubDiv = signatureParams[1];
        if(noteSubDiv.intValue > 0 && beatsPerMeasure.intValue > 0){
            self.instrument.track.timeSignature.noteSubDiv = noteSubDiv.intValue;
            self.instrument.track.timeSignature.beatsPerMeasure = beatsPerMeasure.intValue;
            NSLog(@"Changed time signature to %d / %d", beatsPerMeasure.intValue, noteSubDiv.intValue);
        }
        else{
            NSLog(@"invalid - beats %d / note %d", beatsPerMeasure.intValue, noteSubDiv.intValue);
        }
    }
    else{
        NSLog(@"No valid time signature");
    }
    [self updateParams];
    
}

- (IBAction)clearTrack:(NSButton *)sender {
    [self.instrument clearTrack];
}

- (void) updateParams{
    //update measure duration
    [self.instrument.track.measure updateMeasure];
    float duration = [self.instrument.track.measure totalDuration];
    self.totalDuration.floatValue = duration;
}


//observer of values that change in the instrument object, use to update view
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    
    if ([keyPath isEqual:@"currentMeasureCount"]) {
        self.measureCounter.intValue = self.instrument.track.clickTrack.currentMeasureCount;
    }
    
    else if ([keyPath isEqual:@"currentBeatInMeasure"]) {
        self.beatCounter.intValue = self.instrument.track.clickTrack.currentBeatInMeasure;
    }
    /*
     Be sure to call the superclass's implementation *if it implements it*.
     NSObject does not implement the method.
     */
    
}

@end

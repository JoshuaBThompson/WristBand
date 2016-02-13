//
//  ViewController.swift
//  MidiDevice
//
//  Created by sofiebio on 2/12/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import UIKit
import AudioKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    let midiServiceUUID = "03B80E5A-EDE8-4B33-A751-6CE34EC4C700"
    let midiIOUUID = "7772E5DB-3868-4112-A1A9-F2669D106BF3"
    var midiDevices = [CBPeripheral]()
    var midiData: CBCharacteristic!
    var audioMidiSetupEn = true
    var bleManager: CBCentralManager!
    var connectStatus = "Disconnected"
    var autoConnect = false
    var midiPeripheral: CBPeripheral!
    var deviceName: String!
    var manufactureName: String!
    
    //UUID Constants
    let CBUUIDGenericAccessProfileString = "1800"
    let CBUUIDDeviceNameString = "2A00"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bleManager = CBCentralManager.init(delegate: self, queue: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: start receiving midi handler
    
    /*
    Start bluetooth characteristic notify to receive midi data from device
    */
    func startReceivingMidi(){
        if(( midiData) != nil)
        {
            /* Set indication on midi io characteristic */
            midiPeripheral.setNotifyValue(true, forCharacteristic: midiData)
        }
    }
    
    //MARK: check if ble capable
    
    func isLECapableHardware()->Bool{
        var state: String!
        
        switch bleManager.state {
        case .Unsupported:
            state = "The Platform/Hardware doesn't support Bluetooth Low Energy"
            break
        case .Unauthorized:
            state = "The app is not authorized to use Bluetooth Low Energy"
            break
        case .PoweredOff:
            state = "Bluetooth is currently powered off"
        case .PoweredOn:
            return true
        case .Unknown:
            state = "Unknown Bluetooth state"
        default:
            return false
        }
        print(state)
        return false
    }
    
    //MARK: CBCentralManagerDelegate protocol methods
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        print("Did connect to peripheral: %s", peripheral)
        print("CB Central Manager State: %ld", bleManager.state);
        print("Number of services %lul", CUnsignedLong(peripheral.services!.count));
        
        connectStatus = "Connected";
        //[self.connectButton setTitle:@"Connected!"];
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        //update midiDevices array with peripherals
        print("Discovered peripheral: %s rssi %s AdvData %s", peripheral, RSSI, advertisementData)
    
        if !midiDevices.contains(peripheral){
            midiDevices.append(peripheral)
        }
        
        /* Retreive already known devices */
        if(autoConnect)
        {
            bleManager.retrievePeripheralsWithIdentifiers([peripheral.identifier])
            
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Fail to connect to peripheral: %@ with error = %@", peripheral, error?.localizedDescription)
        if( midiPeripheral != nil)
        {
            midiPeripheral.delegate = nil
            midiPeripheral = nil
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        //check state and print
        isLECapableHardware()
    }
    
    
    //MARK: CBPeripheralDelegate protocol methods
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if ((error) != nil)
        {
            print("Discovered characteristics for %s with error: %s", service.UUID, error?.localizedDescription)
            return
        }
        
        if(service.UUID == CBUUID.init(string: midiServiceUUID))
        {
            for characteristic in service.characteristics!
            {
                /* Set indication on midi io */
                if(characteristic.UUID == CBUUID.init(string: midiIOUUID))
                {
                    midiData = characteristic
                    print("Found a MIDI IO Characteristic !! %s", midiData)
                }
                
            }
            
            startReceivingMidi()
        }
        
        
        if (service.UUID == CBUUID.init(string:CBUUIDGenericAccessProfileString) )
        {
            for characteristic in service.characteristics!
            {
                /* Read device name */
                if(characteristic.UUID == CBUUID.init(string:CBUUIDDeviceNameString))
                {
                    print("Found a Device Name Characteristic - Read device name")
                    midiPeripheral.readValueForCharacteristic(characteristic)
                }
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Discovering services for peripheral!! %s", peripheral)
        if ((error) != nil)
        {
            print("Discovered services for %s with error: %s", peripheral.name, error?.localizedDescription)
            return
        }
        for service in peripheral.services!
        {
            print("Service found with UUID: %s", service.UUID);
            
            if(service.UUID == CBUUID.init(string: midiServiceUUID))
            {
                /* Midi BLE Service */
                midiPeripheral.discoverCharacteristics([CBUUID.init(string: midiIOUUID)], forService:service)
            }
 
            else if(service.UUID == CBUUID.init(string: "180A"))
            {
                /* Device Information Service - discover manufacture name characteristic */
                midiPeripheral.discoverCharacteristics([CBUUID.init(string: "2A29")], forService: service)
            }
            else if (service.UUID == CBUUID.init(string: CBUUIDGenericAccessProfileString ) ) //1800 is the Gen access profile string
            {
                /* GAP (Generic Access Profile) - discover device name characteristic */
                midiPeripheral.discoverCharacteristics([CBUUID.init(string: CBUUIDDeviceNameString)], forService: service)
                //2A00 is the device name string
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if ((error) != nil)
        {
            print("Error updating value for characteristic %s error: %s", characteristic.UUID, error?.localizedDescription)
            return
        }
        
        /* Value for midi data received */
        if(characteristic.UUID == CBUUID.init(string: midiIOUUID))
        {
            print("Midi Response= %s", characteristic)
            print("MIDI Response Data = %s", characteristic.value)
            if(!audioMidiSetupEn){
                //todo: add instrument and midiNotOn
                //instrument.midiNoteOn()
            }
        }
        
        /* Value for device name received */
        if(characteristic.UUID == CBUUID.init(string:CBUUIDDeviceNameString))
        {
            deviceName = String.init(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            print("Device Name = %s", deviceName)
        }
        
        /* Value for manufacturer name received */
        if(characteristic.UUID == CBUUID.init(string:"2A29"))
        {
            manufactureName = String.init(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            print("Manufacturer Name = %s", manufactureName)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if ((error) != nil)
        {
            print("Error writing value for characteristic %s error: %s", characteristic.UUID, error?.localizedDescription)
            return
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if ((error) != nil)
        {
            print("Error updating notification state for characteristic %s error: %s", characteristic.UUID, error?.localizedDescription);
            return
        }
        
        print("Updated notification state for characteristic %s (newState:%s)", characteristic.UUID, characteristic.isNotifying ? "Notifying" : "Not Notifying")
        
        if(characteristic.UUID == CBUUID.init(string: midiIOUUID))
        {
            
        }
    }


}


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
    var track: Track!
    let midiServiceUUID = "03B80E5A-EDE8-4B33-A751-6CE34EC4C700"
    let midiIOUUID = "7772E5DB-3868-4112-A1A9-F2669D106BF3"
    var midiDevices = [CBPeripheral]()
    var midiData: CBCharacteristic!
    var audioMidiSetupEn = true
    var bleManager: CBCentralManager!
    var connectStatus = "Disconnected"
    var autoConnect = true
    var midiPeripheral: CBPeripheral!
    var deviceName: String!
    var manufactureName: String!
    
    //UUID Constants
    let CBUUIDGenericAccessProfileString = "1800"
    let CBUUIDDeviceNameString = "2A00"
    
    //MARK: outlets
    
    
    @IBOutlet weak var debugLabel: UILabel!
    
    
    //MARK: actions
    
    @IBAction func addNote1(sender: UIButton) {
        track.addNote1()
    }
    
    @IBAction func addNote2(sender: UIButton) {
        track.addNote2()
    }
    
    @IBAction func addNote3(sender: UIButton) {
        track.addNote3()
    }
    
    
    @IBAction func playTrack(sender: UIButton) {
        track.play()
    }
    
    @IBAction func stopTrack(sender: UIButton) {
        track.stop()
    }
    
    
    @IBAction func Connect(sender: UIButton) {
        debugLabel.text = "Connecting to bluetooth device"
        if( autoConnect )
        {   debugLabel.text = "Starting scan"
            startScan()
        }
    }
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bleManager = CBCentralManager.init(delegate: self, queue: nil)
        debugLabel.text = "View did load"
        track = Track()
        track.start()
        
    }
    
    //MARK: Start scan for ble peripherals
    func startScan(){
        if(bleManager.state==CBCentralManagerState.PoweredOn){
            debugLabel.text = "Scanning for unconnectedDevices"
            audioMidiSetupEn = false
            bleManager.scanForPeripheralsWithServices([CBUUID.init(string: midiServiceUUID)], options:nil)
        }
        else{
            debugLabel.text = "ble not enabled on device"
        }
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
        debugLabel.text = state
        return false
    }
    
    
    //MARK: CBCentralManagerDelegate protocol methods
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        let status = String(format: "Connected to peripheral: %s", peripheral)
        debugLabel.text = status
        
        connectStatus = "Connected";
        //[self.connectButton setTitle:@"Connected!"];
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        //update midiDevices array with peripherals
        debugLabel.text = "Discovered peripheral"
        let status = String(format: "Discovered peripheral: %s rssi %s AdvData %s", peripheral, RSSI, advertisementData)
        debugLabel.text = status
    
        if !midiDevices.contains(peripheral){
            midiDevices.append(peripheral)
        }
        
        /* Retreive already known devices */
        if(autoConnect)
        {
            bleManager.stopScan()
            debugLabel.text = "Discovered peripheral, autoconnecting to midiDevice"
            debugLabel.text = status
            midiPeripheral = peripheral
            midiPeripheral.delegate = self
            bleManager.connectPeripheral(peripheral, options: nil)
            
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let status = String(format: "Fail to connect to peripheral: %s with error = %s", peripheral, (error?.localizedDescription)!)
        debugLabel.text = status
        if( midiPeripheral != nil)
        {
            midiPeripheral.delegate = nil
            midiPeripheral = nil
        }
        bleManager.stopScan()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        //check state and print
        isLECapableHardware()
    }
    
    
    //MARK: CBPeripheralDelegate protocol methods
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if ((error) != nil)
        {

            debugLabel.text = String("Failed to discover characteristic for service %s", service.UUID)
            return
        }
        
        if(service.UUID == CBUUID.init(string: midiServiceUUID))
        {
            debugLabel.text = "Discovering characteristics for midi service"
            for characteristic in service.characteristics!
            {
                let thisCharacteristic = characteristic as CBCharacteristic
                
                /* Set indication on midi io */
                if(characteristic.UUID == CBUUID.init(string: midiIOUUID))
                {
                    debugLabel.text = String(format:"Discovered char for service %s", service.UUID)
                    midiData = thisCharacteristic
                    debugLabel.text = "Found MIDI IO Characteristic"
                    midiPeripheral.setNotifyValue(true, forCharacteristic: midiData)
                }
                
            }
            
            //startReceivingMidi()
        }
        
        
        if (service.UUID == CBUUID.init(string:CBUUIDGenericAccessProfileString) )
        {
            for characteristic in service.characteristics!
            {
                /* Read device name */
                if(characteristic.UUID == CBUUID.init(string:CBUUIDDeviceNameString))
                {
                    debugLabel.text = "Found device name characteristic"
                    //midiPeripheral.readValueForCharacteristic(characteristic)
                }
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        debugLabel.text = String("Discovering services for peripheral!! %s", peripheral)
        if ((error) != nil)
        {
            debugLabel.text = "Discover services error"
            return
        }
        for service in peripheral.services!
        {
            debugLabel.text = String(format: "Service found with UUID %s", service.UUID)
            let thisService = service as CBService
            
            if(service.UUID == CBUUID.init(string: midiServiceUUID))
            {
                /* Midi BLE Service */
                debugLabel.text = "Discovered midi ble service"
                midiPeripheral.discoverCharacteristics([CBUUID.init(string: midiIOUUID)], forService:thisService)
            }
 
            else if(service.UUID == CBUUID.init(string: "180A"))
            {
                debugLabel.text = "Discovered 180A service"
                /* Device Information Service - discover manufacture name characteristic */
                midiPeripheral.discoverCharacteristics([CBUUID.init(string: "2A29")], forService: thisService)
            }
            else if (service.UUID == CBUUID.init(string: CBUUIDGenericAccessProfileString ) ) //1800 is the Gen access profile string
            {
                debugLabel.text = "Discovered GAP service"
                /* GAP (Generic Access Profile) - discover device name characteristic */
                midiPeripheral.discoverCharacteristics([CBUUID.init(string: CBUUIDDeviceNameString)], forService: thisService)
                //2A00 is the device name string
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if ((error) != nil)
        {

            debugLabel.text = "Error updating value for characteristic"
            return
        }
        
        /* Value for midi data received */
        if(characteristic.UUID == CBUUID.init(string: midiIOUUID))
        {
            debugLabel.text = String(format:"MIDI Response Data = %s", characteristic.value!)
            if(!audioMidiSetupEn){
                //todo: add instrument and midiNotOn
            }
        }
        
        /* Value for device name received */
        if(characteristic.UUID == CBUUID.init(string:CBUUIDDeviceNameString))
        {
            deviceName = String.init(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            debugLabel.text = String(format: "Device name = %s", deviceName)
        }
        
        /* Value for manufacturer name received */
        if(characteristic.UUID == CBUUID.init(string:"2A29"))
        {
            manufactureName = String.init(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            debugLabel.text = String(format: "Manufacturer's name = %s", manufactureName)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if ((error) != nil)
        {
 
            debugLabel.text = "Error writing value for characteristic"
            return
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if ((error) != nil)
        {
            debugLabel.text = "Error updating notification state for characteristic"
            return
        }
        
        debugLabel.text = "Updating notification state for characteristic"
        
        if(characteristic.UUID == CBUUID.init(string: midiIOUUID))
        {
            debugLabel.text = "Got some midi data"
            
        }
    }


}


//
//  DeviceStore.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/14/21.
//

import SwiftUI
import Combine
import CoreBluetooth

class DeviceStore :NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var devices: [Device]{
        didSet{didChange.send()}
    }
    @Published var deviceData: DeviceData
    
    //let GENERIC_ACCESS_SERVICE_UUID = CBUUID(string: "00001800-0000-1000-8000-00805f9b34fb");
    let GENERIC_ACCESS_SERVICE_UUID = CBUUID(string: "0x1800")
    let DEVICE_NAME_CHARACTERISTIC_UUID = CBUUID(string: "0x2A00")
    
    let MOTOR_CONTROL_SERVICE_UUID = CBUUID(string: "74b0d4c7-d0b4-4134-af7f-d92cb0a83b0d")
    let RPM_CHARACTERISTICS_UUID = CBUUID(string: "b1f8b319-fc1c-4756-a391-f56dfa101b24")
    let GO_CHARACTERISTIC_UUID = CBUUID(string: "02f2ec80-ce47-4383-9e41-170fc6fe06fe")
    let FLOW_INDEX_CHARACTERISTIC_UUID = CBUUID(string: "47844164-f734-40bd-8469-c38c02382046")
    let RPM_ALARM_STATUS_CHARACTERISTIC_UUID = CBUUID(string: "809f3fff-41bf-4c72-a6b0-fb88f4218bbe")
    
    let SECURITY_SERVICE_UUID = CBUUID(string: "3a658e10-af85-4163-9607-094fdaeb3859")
    let GET_ALL_PASSWORD_ENABLE_STATES_CHARACTERISTIC_UUID = CBUUID(string: "ee45ab48-b6b8-4f2a-83db-86e9011fd40a");
    
    let FACTORY_SERVICE_UUID = CBUUID(string: "b7da3a79-a0df-45d9-bd85-f165605e2a04")
    let RF_SERVICE_UUID = CBUUID(string: "d3ecc05a-5192-43f8-a409-84faca67e7b0")
    
    let FILTER_MONITORING_SERVICE = CBUUID(string: "9f8d8050-9731-4597-85a0-d49fba2db671")
    let RESET_FILTER1_ALARM_CHARACTERISTIC_UUUID = CBUUID(string: "1aaf1b0e-b754-11eb-8529-0242ac130003")
    let RESET_FILTER2_ALARM_CHARACTERISTIC_UUID = CBUUID(string: "1aaf1dac-b754-11eb-8529-0242ac130003")
    let RESET_FILTER3_ALARM_CHARACTERISTIC_UUID = CBUUID(string: "1aaf1ea6-b754-11eb-8529-0242ac130003")
    let FILTER_MONITORING_ENABLE_STATUS_CHARACTERISTIC_UUID = CBUUID(string: "1aaf1f6e-b754-11eb-8529-0242ac130003")
    let REMAINING_FILTER_LIVES_CHARACTERISTIC_UUID = CBUUID(string: "1aaf24d2-b754-11eb-8529-0242ac130003")
    let FILTER1_NAME_CHARACTERISTIC_UUID = CBUUID(string: "8524b1f2-4ce9-466f-9886-238937741bf5")
    let FILTER2_NAME_CHARACTERISTIC_UUID = CBUUID(string: "ac2b933e-a782-4841-af93-377cdd6f521c");
    let FILTER3_NAME_CHARACTERISTIC_UUID = CBUUID(string: "d08c2d65-c3e1-464d-b2a5-8387959fe5de");
    
    let SILICON_LABS_OTA_SERVICE_UUID = CBUUID(string: "1D14D6EE-FD63-4FA1-BFA4-8F47B42119F0")
    
    //var MOTOR_CONTROL_CHARACTERISTICS_UUIDS = [RPM_CHARACTERISTICS_UUID, ]
//    @Published var RPM: Int
//    @Published var type: String
    
    var centralManager: CBCentralManager?
    var connected = false
    var targetPeripheral: CBPeripheral?
    var flowIndexCharacteristic: CBCharacteristic?
    var deviceNameCharacteristic: CBCharacteristic?
    var RPMAlarmStatusCharacteristic: CBCharacteristic?
    var securityService: CBService?
    var filterMonitorEnableCharacteristic: CBCharacteristic?
    var filterMonitor1ResetCharacteristic: CBCharacteristic?
    var filterMonitor2ResetCharacteristic: CBCharacteristic?
    var filterMonitor3ResetCharacteristic: CBCharacteristic?
    var filterRemainingLivesCharacteristic: CBCharacteristic?
    var filter1NameCharacteristic: CBCharacteristic?
    var filter2NameCharacteristic: CBCharacteristic?
    var filter3NameCharacteristic: CBCharacteristic?
    
    @Published var speed: Double = 0.0
    
    init(devices: [Device] = []){
        self.devices = devices
        self.deviceData = DeviceData()
        super.init()
        // This will result in CBCentralManager calling
        // func centralManagerDidUpdateState(_ central: CBCentralManager)
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func setData( _ data: DeviceData){
        deviceData = data
    }
    
    var didChange = PassthroughSubject<Void, Never>()
    
    func startScan(){
        //scan for ble devices
        // This will result in CBCentralManager calling centralManager(_: didDiscover: advertisementData: rssi: )
        centralManager?.scanForPeripherals(withServices: nil)
    }
    
    func stopScan(){
        centralManager?.stopScan()
    }
    
    func clearStore(){
        self.devices.removeAll()
    }
    
    // This is the CBCentralManagerDelegate for instantiating centralManager in init
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
            case .unknown:
                // Wait for next state update
                print("central.state is .unkown")
            case .resetting:
                // Wait for next state update and consider logging interruption of Bluetooth service
                print("central.state is .resetting")
            case .unsupported:
                // Alert user their device does not support Bluetooth and app will not work as expected
                print("central.state is .unsupported")
            case .unauthorized:
                // user denied bluetooth access for this app
                // Alert user to enable Bluetooth permission in app Settings
                print("central.state is .unauthorized")
            case .poweredOff:
                // Alert user to turn on Bluetooth
                print("central.state is .poweredoff")
            case .poweredOn:
                print("central.state is .poweredOn")
            default:
                print("default cases")
                
        }
    }
    
    //
    // delegate to handle centralManager?.scanForPeripherals results
    //
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let data = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            let dataArray = [UInt8](data)
            if( dataArray[0] == Character("E").asciiValue && dataArray[1] == Character("V").asciiValue && dataArray[2] == Character("O").asciiValue)
            {
                // check alarm status
                if dataArray[3] & 0xF0 == 0 { }
                let newDevice = Device(id: peripheral.identifier, deviceRSSI: Int(truncating: RSSI), peripheral: peripheral, type: Int((dataArray[3] & 0xF0) >> 4))
                self.devices.append(newDevice)
                let count = devices.count
                print("peripherals count = \(count)")
                for i in 0...count-1 {
                    print(devices[i].peripheral)
                }
            }
        }
    }
    
    func connect(targetPeripheral peripheral: CBPeripheral){
        // This will result in CBCentralManager calling
        //func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
        centralManager?.connect(peripheral)
        targetPeripheral = peripheral
        targetPeripheral?.delegate = self
    }
    
    func disconnect(targetPeripheral peripheral: CBPeripheral){
        if connected {
            // This call will result in CBCentralManager calling
            // centralManager(_:didDisconnectPeripheral:error:)  delegate
            centralManager?.cancelPeripheralConnection(peripheral)
            connected = false
            targetPeripheral = nil
        }
    }
    
    //
    // delegate to handle centralManager?.connect(peripheral) results
    //
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        connected = true;
        // This will result in CBPeripheral calling
        // func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) in
        // the extension DeviceStore: CBPeripheralDelegate
        targetPeripheral?.discoverServices(nil)
        //targetPeripheral?.discoverServices(Array(_immutableCocoaArray: GENERIC_ACCESS_SERVICE_UUID))
    }
    
    //
    // delegate to handle centralManager?.cancelPeripheralConnection(peripheral) results
    //
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
                // Handle error
                return
            }
        // Successfully disconnected
        print("successfully disconnected from peripheral")
    }
}

extension DeviceStore: CBPeripheralDelegate {
    //
    // delegate to handle targetPeripheral?.discoverServices(nil) results
    //
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let er = error {
            print(er.localizedDescription)
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            if service.uuid.isEqual(MOTOR_CONTROL_SERVICE_UUID) {
                print("Motor control service found")
                // This will result in CBPeripheral calling
                // func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) delegate
                peripheral.discoverCharacteristics(nil, for: service)
            }
            else if service.uuid.isEqual(SECURITY_SERVICE_UUID) {
                print("Security service found")
                peripheral.discoverCharacteristics(nil, for: service)
                securityService = service
            }
            else if service.uuid.isEqual(FACTORY_SERVICE_UUID) {
                print("Factory service found")
            }
            else if service.uuid.isEqual(RF_SERVICE_UUID) {
                print("RF service found")
            }
            else if service.uuid.isEqual(FILTER_MONITORING_SERVICE) {
                print("Filter monitoring service found")
                peripheral.discoverCharacteristics(nil, for: service)
            }
            // The discover service does not return Generic Access Profile (GAP) service
            else if service.uuid.isEqual( GENERIC_ACCESS_SERVICE_UUID ){
                print("Generic access service found")
            }
            else if service.uuid.isEqual( SILICON_LABS_OTA_SERVICE_UUID ) {
                print("Silicon Labs OTA Service found")
            }
            
        }
    }
    
    //
    // Delegate to handle peripheral.discoverCharacteristics reaults
    //
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if service.uuid.isEqual(MOTOR_CONTROL_SERVICE_UUID) {
            guard let characteristics = service.characteristics else { print("no motor control characteristics found"); return }
            
                for characteristic in characteristics {
                    print(characteristic)
                    if characteristic.uuid.isEqual(RPM_CHARACTERISTICS_UUID){
                        print("found RPM characteristic")
                        // This will result in CBPeripheral calling
                        //func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
                        // when  new vlaue is received from peripheral
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    else if characteristic.uuid.isEqual(GO_CHARACTERISTIC_UUID){
                        print("found GO characteristic")
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    else if characteristic.uuid.isEqual(FLOW_INDEX_CHARACTERISTIC_UUID){
                        print("found Flow Index characteristic")
                        peripheral.setNotifyValue(true, for: characteristic)
                        flowIndexCharacteristic = characteristic
                    }
                    else if characteristic.uuid.isEqual(RPM_ALARM_STATUS_CHARACTERISTIC_UUID){
                        RPMAlarmStatusCharacteristic = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
            }
        }
        else if service.uuid.isEqual(SECURITY_SERVICE_UUID) {
            guard let characteristics = service.characteristics else { print("no security settings characteristics found"); return }
            
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(GET_ALL_PASSWORD_ENABLE_STATES_CHARACTERISTIC_UUID){
                    print("found get all password enable states characteristic")
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        else if service.uuid.isEqual(FILTER_MONITORING_SERVICE) {
            guard let characteristics = service.characteristics else { print("no Filter Monitoring characteristics found"); return }
            
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(FILTER1_NAME_CHARACTERISTIC_UUID){
                    filter1NameCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(FILTER2_NAME_CHARACTERISTIC_UUID) {
                    filter2NameCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(FILTER3_NAME_CHARACTERISTIC_UUID) {
                    filter3NameCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(REMAINING_FILTER_LIVES_CHARACTERISTIC_UUID) {
                    filterRemainingLivesCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                else if characteristic.uuid.isEqual(FILTER_MONITORING_ENABLE_STATUS_CHARACTERISTIC_UUID) {
                    filterMonitorEnableCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(RESET_FILTER1_ALARM_CHARACTERISTIC_UUUID) {
                    filterMonitor1ResetCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(RESET_FILTER2_ALARM_CHARACTERISTIC_UUID) {
                    filterMonitor2ResetCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(RESET_FILTER3_ALARM_CHARACTERISTIC_UUID) {
                    filterMonitor3ResetCharacteristic = characteristic
                }
            }
            
        }
    }
    
    //
    // delegate function to handle notification from pheripheral
    //
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
        if characteristic.uuid.isEqual(RPM_CHARACTERISTICS_UUID){
            deviceData.RPM = Int(convert_Data_to_Int( characteristicData: characteristic.value ))
        }
        else if characteristic.uuid.isEqual(GO_CHARACTERISTIC_UUID){
            if let go_data = characteristic.value {
                    deviceData.go = go_data[0] != 0 // when not 0, the motor is running
            }
        }
        else if characteristic.uuid.isEqual(FLOW_INDEX_CHARACTERISTIC_UUID ){
            if let flow_index_data = characteristic.value {
                let temp = flow_index_data[0]
                deviceData.speed = Int(temp)
                speed = Double(temp)
                print(deviceData.speed)
            }
        }
        else if characteristic.uuid.isEqual(GET_ALL_PASSWORD_ENABLE_STATES_CHARACTERISTIC_UUID){
            if let passwordEnableStates = characteristic.value {
                deviceData.userPasswordEnabled = (passwordEnableStates[0] & 0x01) == 0x01
                deviceData.adminPasswordEnabled = (passwordEnableStates[0] & 0x02) == 0x02
            }
        }
        else if characteristic.uuid.isEqual(REMAINING_FILTER_LIVES_CHARACTERISTIC_UUID) {
            if let filterRemainingLives = characteristic.value {
                deviceData.filterMonitors[0].filterRemainingLife = Int(filterRemainingLives[0])
                deviceData.filterMonitors[1].filterRemainingLife = Int(filterRemainingLives[1])
                deviceData.filterMonitors[2].filterRemainingLife = Int(filterRemainingLives[2])
            }
        }
        else if characteristic.uuid.isEqual(FILTER_MONITORING_ENABLE_STATUS_CHARACTERISTIC_UUID)
        {
            if let filterEnableStates = characteristic.value {
                deviceData.filterMonitors[0].filterEnabled = (filterEnableStates[0] & 0x01) == 0x01
                deviceData.filterMonitors[1].filterEnabled = (filterEnableStates[0] & 0x02) == 0x02
                deviceData.filterMonitors[2].filterEnabled = (filterEnableStates[0] & 0x04) == 0x04
            }
        }
        else if characteristic.uuid.isEqual(RPM_ALARM_STATUS_CHARACTERISTIC_UUID){
            if let RPMAlarmStatus = characteristic.value {
                deviceData.RPMInAlarm = RPMAlarmStatus[0] == 0x01
            }
        }
            
    }

    
    func convert_Data_to_Int( characteristicData newData :Data?) -> Int16
    {
        var ret: Int16
        
        guard let data = newData else { return -1 }
        
        if data.count < 2 {
            return -1
        }
        
        ret = 0
        
        for i in 0...1  {
            let temp = data[i]
            ret += Int16(temp) << (i * 8)
        }
        
        return ret
    }
    
    func sendFlowIndex()
    {
        print(speed)

        if let characteristic = flowIndexCharacteristic {
            let bytes: [UInt8] = [UInt8(speed)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func sendDeviceName(NewDeviceName newName: String )
    {
        print("The new name is \(newName)." )
    }
    
    func sendSecurityStuff(characteristicUUID uuid: CBUUID, Data data: NSData ){
        
    }
    
    func getFilterEnableStatus()
    {
        if let characteristic = filterMonitorEnableCharacteristic {
            if let peripheral = targetPeripheral {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func resetRPMAlarm(){
        let bytes: [UInt8] = [0]
        let data: NSData = NSData(bytes: bytes, length: bytes.count)
        if let peripheral = targetPeripheral {
            if let characteristic = RPMAlarmStatusCharacteristic {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    
    func resetFilter(FilterIndes index: Int){
        let bytes: [UInt8] = [0]
        let data: NSData = NSData(bytes: bytes, length: bytes.count)
        if let peripheral = targetPeripheral {
            switch index {
            case 0:
                if let characteristic = filterMonitor1ResetCharacteristic {
                    peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
                }
            case 1:
                if let characteristic = filterMonitor2ResetCharacteristic {
                    peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
                }
            case 2:
                if let characteristic = filterMonitor3ResetCharacteristic {
                    peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
                }
            default:
                print("filter index error")
            }
        }
    }
}


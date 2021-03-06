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
    @Published var deviceData: DeviceData?
    
    var isAliveListener : IsBLEConnectionAliveListener?
    var lostConnectionCount = 0
    
    //let GENERIC_ACCESS_SERVICE_UUID = CBUUID(string: "00001800-0000-1000-8000-00805f9b34fb");
    let GENERIC_ACCESS_SERVICE_UUID = CBUUID(string: "0x1800")
    let DEVICE_NAME_CHARACTERISTIC_UUID = CBUUID(string: "0x2A00")
    
    let MOTOR_CONTROL_SERVICE_UUID = CBUUID(string: "74b0d4c7-d0b4-4134-af7f-d92cb0a83b0d")
    let RPM_CHARACTERISTICS_UUID = CBUUID(string: "b1f8b319-fc1c-4756-a391-f56dfa101b24")
    let GO_CHARACTERISTIC_UUID = CBUUID(string: "02f2ec80-ce47-4383-9e41-170fc6fe06fe")
    let FLOW_INDEX_CHARACTERISTIC_UUID = CBUUID(string: "47844164-f734-40bd-8469-c38c02382046")
    let RPM_ALARM_STATUS_CHARACTERISTIC_UUID = CBUUID(string: "809f3fff-41bf-4c72-a6b0-fb88f4218bbe")
    let GET_MOTOR_SETTINGS_CHARACTERISTIC_UUID = CBUUID(string: "28f4cdcd-5276-4f7c-afdb-16d613ab5e22")
    
    let SECURITY_SERVICE_UUID = CBUUID(string: "3a658e10-af85-4163-9607-094fdaeb3859")
    let GET_ALL_PASSWORD_ENABLE_STATES_CHARACTERISTIC_UUID = CBUUID(string: "ee45ab48-b6b8-4f2a-83db-86e9011fd40a")
    let USER_PASSWORD_VERIFIED_CHARACTERISTIC_UUID = CBUUID(string: "e958246c-32ba-4243-a945-42daf45c22df")
    let ADMIN_PASSWORD_VERIFIED_CHARACTERISTIC_UUID = CBUUID(string: "6d873ad3-8327-4943-9bd5-481daffab853")
    let VERIFY_USER_PASSWORD_CHARACTERISTIC_UUID = CBUUID(string: "2fc0c709-e8b8-45f8-a917-ef9dd902b4cb")
    let VERIFY_ADMIN_PASSWORD_CHARACTERISTIC_UUID = CBUUID(string: "1ffa6379-38b1-4861-be7c-7722dcb6c917");
    let USER_PASSWORD_CHARACTERISTIC = CBUUID(string: "f756319c-aaa1-4ac1-b7cc-527345b6b423")
    let ADMIN_PASSWORD_CHARACTERISTIC = CBUUID(string: "63997a5d-5cc1-49d0-bbfc-3637fbd465b9")
    let ENABLE_USER_PASSWORD_CHARACTERISTIC = CBUUID(string: "dc4688f1-c4b3-4d9f-b6e1-690ed22f58b4")
    let ENABLE_ADMIN_PASSWORD_CHARACTERISTIC = CBUUID(string: "47fb6cef-a280-4162-b897-7b8fcf5fff48")
    
    let FACTORY_SERVICE_UUID = CBUUID(string: "b7da3a79-a0df-45d9-bd85-f165605e2a04")
    // We need this Write device name through a characteristic in the factory service becuase
    // ios does not allow writing and changing the device name thoufh the GAP
    let WRITE_DEVICE_NAME_THROUGH_GATT_CHARACTERISTIC_UUID = CBUUID(string: "9c81b0bd-b2d4-4439-9f87-3dd9a454baf3")
    let VERSION_CHARACTERISTIC_UUID = CBUUID(string: "fa39dccc-60c4-463a-b8c8-6ec6713923b6")
    
    let RF_SERVICE_UUID = CBUUID(string: "d3ecc05a-5192-43f8-a409-84faca67e7b0")
    let RSSI_CHARACTERISTIC_UUID = CBUUID(string: "dbd823a0-5f72-4d36-b868-ab5c56301e90")
    
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
//    var filter1NameCharacteristic: CBCharacteristic?
//    var filter2NameCharacteristic: CBCharacteristic?
//    var filter3NameCharacteristic: CBCharacteristic?
    var writeDeviceNameThroughGATTCharacteristic: CBCharacteristic?
    var verifyUserPasswordCharacteristic: CBCharacteristic?
    var verifyAdminPasswordCharacteristic: CBCharacteristic?
    var userPasswordCharacteristic: CBCharacteristic?
    var adminPasswordCharacteristic: CBCharacteristic?
    var enableUserPasswordCharacteristic: CBCharacteristic?
    var enableAdminPasswordCharacteristic: CBCharacteristic?
    var mobileRSSIinDeviceCharacteristic: CBCharacteristic?
    
    @Published var output: Double = 0.0
    
    init(devices: [Device] = []){
        self.devices = devices
        self.deviceData = nil
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
            let rssi = Int(truncating: RSSI)
            if ( rssi > -95)
            {
                if( dataArray[0] == Character("E").asciiValue && dataArray[1] == Character("V").asciiValue && dataArray[2] == Character("O").asciiValue)
                {
                    // ios always uses the cached device name instead of using the name in the kCBAdvDataLocalName key.
                    // This causes big problem after a name change.
                    var DeviceName = ""
                    // In case something is wrong and we cannot get name from kCBAdvDataLocalName key,
                    // we can still display the device with no name and still able to access the control
                    if let Name = advertisementData["kCBAdvDataLocalName"] as? String {
                        DeviceName = Name
                    }
                    
                    // bit 0 of dataArray[3] is RPM alarm status for all versions
                    // bit 1 is the filter monitor alarm for major version 3 and higher
                    // bit 2 and 3 are reserved for future use
                    // bit 4 to 7 are reserved for device type. 0 is ECM10-BTH1, the developement name for ECM-BCU.
                    
                    if dataArray[3] & 0xF0 == 0 { }  // detect device type. We only have one type for now
                    let newDevice = Device(id: peripheral.identifier, deviceRSSI: Int(truncating: RSSI), peripheral: peripheral, type: Int((dataArray[3] & 0xF0) >> 4), inAlarm: dataArray[3] & 0x03 != 0, deviceName: DeviceName)
                    self.devices.append(newDevice)
                    let count = devices.count
                    print("peripherals count = \(count)")
                    for i in 0...count-1 {
                        print(devices[i].peripheral)
                    }
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
            lostConnectionCount = 0
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
    
    func isBLEConectionStillAlive() {
        if self.targetPeripheral?.state != CBPeripheralState.connected {
            if lostConnectionCount == 5 {
                self.isAliveListener?.bluetoothLost()
            }
            else {
                lostConnectionCount += 1;
            }
        }
    }
}

// protocol to detect ble connection disconnected.
protocol IsBLEConnectionAliveListener {
    func bluetoothLost()
}

extension DeviceStore: CBPeripheralDelegate {
    
    //
    // delegate to handle targetPeripheral?.readRSSI results
    //
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?)
    {
        if let data = deviceData {
            data.UpdateDeviceRSSIinMobile(Int(truncating: RSSI))
        }
    }
    
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
                peripheral.discoverCharacteristics(nil, for: service)
            }
            else if service.uuid.isEqual(RF_SERVICE_UUID) {
                print("RF service found")
                peripheral.discoverCharacteristics(nil, for: service)
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
        
        if let er = error {
            print(er.localizedDescription)
            return
        }
        
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
                        print("found RPM Alarm status characteristic")
                        RPMAlarmStatusCharacteristic = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    else if characteristic.uuid.isEqual(GET_MOTOR_SETTINGS_CHARACTERISTIC_UUID){
                        print("found get motor settings characteristic")
                        peripheral.readValue(for: characteristic)
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
                else if characteristic.uuid.isEqual(ADMIN_PASSWORD_VERIFIED_CHARACTERISTIC_UUID){
                    print("found get admin password verified characteristic")
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                }
                else if characteristic.uuid.isEqual(USER_PASSWORD_VERIFIED_CHARACTERISTIC_UUID){
                    print("found get user password verified characteristic")
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                }
                else if characteristic.uuid.isEqual(VERIFY_USER_PASSWORD_CHARACTERISTIC_UUID){
                    print("found get user password characteristic")
                    verifyUserPasswordCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(VERIFY_ADMIN_PASSWORD_CHARACTERISTIC_UUID){
                    print("found get admin password characteristic")
                    verifyAdminPasswordCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(USER_PASSWORD_CHARACTERISTIC) {
                    print("found set user password characteristic")
                    userPasswordCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(ADMIN_PASSWORD_CHARACTERISTIC) {
                    print("found set admin password characteristic")
                    adminPasswordCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(ENABLE_USER_PASSWORD_CHARACTERISTIC) {
                    print("found enable user password characteristic")
                    enableUserPasswordCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(ENABLE_ADMIN_PASSWORD_CHARACTERISTIC) {
                    print("found enable admin password characteristic")
                    enableAdminPasswordCharacteristic = characteristic
                }
            }
        }
        else if service.uuid.isEqual(FILTER_MONITORING_SERVICE) {
            guard let characteristics = service.characteristics else { print("no Filter Monitoring characteristics found"); return }
            
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(FILTER1_NAME_CHARACTERISTIC_UUID){
                    //filter1NameCharacteristic = characteristic
                    peripheral.readValue(for: characteristic)
                }
                else if characteristic.uuid.isEqual(FILTER2_NAME_CHARACTERISTIC_UUID) {
                    //filter2NameCharacteristic = characteristic
                    peripheral.readValue(for: characteristic)
                }
                else if characteristic.uuid.isEqual(FILTER3_NAME_CHARACTERISTIC_UUID) {
                    //filter3NameCharacteristic = characteristic
                    peripheral.readValue(for: characteristic)
                }
                else if characteristic.uuid.isEqual(REMAINING_FILTER_LIVES_CHARACTERISTIC_UUID) {
                    filterRemainingLivesCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                else if characteristic.uuid.isEqual(FILTER_MONITORING_ENABLE_STATUS_CHARACTERISTIC_UUID) {
                    filterMonitorEnableCharacteristic = characteristic
                    peripheral.readValue(for: characteristic)
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
        else if service.uuid.isEqual(FACTORY_SERVICE_UUID){
            guard let characteristics = service.characteristics else { print("no factory characteristics found"); return }
            
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(WRITE_DEVICE_NAME_THROUGH_GATT_CHARACTERISTIC_UUID){
                    writeDeviceNameThroughGATTCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(VERSION_CHARACTERISTIC_UUID) {
                    peripheral.setNotifyValue(true, for: characteristic) //This will trigger device to send version
                }
            }
        }
        else if service.uuid.isEqual(RF_SERVICE_UUID)
        {
            guard let characteristics = service.characteristics else { print("no RF characteristics found"); return }
            
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(RSSI_CHARACTERISTIC_UUID) {
                    mobileRSSIinDeviceCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
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
            if let data = deviceData{
                data.RPM = Int(convert_Data_to_Int( characteristicData: characteristic.value ))
            }
        }
        else if characteristic.uuid.isEqual(GO_CHARACTERISTIC_UUID){
            if let go_data = characteristic.value {
                if let data = deviceData {
                    data.go = go_data[0] != 0 // when not 0, the motor is running
                }
                    
            }
        }
        else if characteristic.uuid.isEqual(FLOW_INDEX_CHARACTERISTIC_UUID ){
            if let flow_index_data = characteristic.value {
                if let data = deviceData {
                    let temp = flow_index_data[0]
                    data.controlOutput = Int(temp)
                    output = Double(temp)
                    print(data.controlOutput)
                }
            }
        }
        else if characteristic.uuid.isEqual(GET_ALL_PASSWORD_ENABLE_STATES_CHARACTERISTIC_UUID){
            if let passwordEnableStates = characteristic.value {
                if let data = deviceData {
                    data.userPasswordEnabled = (passwordEnableStates[0] & 0x01) == 0x01
                    data.adminPasswordEnabled = (passwordEnableStates[0] & 0x02) == 0x02
                    data.PWEnableStatusReceived = true
                    
                    if !data.adminPasswordEnabled {
                        readPasswords()
                    }
                }
               
            }
        }
        else if characteristic.uuid.isEqual(REMAINING_FILTER_LIVES_CHARACTERISTIC_UUID) {
            if let filterRemainingLives = characteristic.value {
                if let data = deviceData {
                    data.filterMonitors[0].filterRemainingLife = Int(filterRemainingLives[0])
                    data.filterMonitors[1].filterRemainingLife = Int(filterRemainingLives[1])
                    data.filterMonitors[2].filterRemainingLife = Int(filterRemainingLives[2])
                }
            }
        }
        else if characteristic.uuid.isEqual(FILTER_MONITORING_ENABLE_STATUS_CHARACTERISTIC_UUID)
        {
            if let filterEnableStates = characteristic.value {
                if let data = deviceData {
                    data.filterMonitors[0].filterEnabled = (filterEnableStates[0] & 0x01) == 0x01
                    data.filterMonitors[1].filterEnabled = (filterEnableStates[0] & 0x02) == 0x02
                    data.filterMonitors[2].filterEnabled = (filterEnableStates[0] & 0x04) == 0x04
                }
            }
        }
        else if characteristic.uuid.isEqual(RPM_ALARM_STATUS_CHARACTERISTIC_UUID){
            if let RPMAlarmStatus = characteristic.value {
                if let data = deviceData {
                    data.RPMInAlarm = RPMAlarmStatus[0] == 0x01
                }
            }
        }
        else if characteristic.uuid.isEqual(ADMIN_PASSWORD_VERIFIED_CHARACTERISTIC_UUID) {
            if let adminPWVerifiedState = characteristic.value{
                if let data = deviceData {
                    data.adminPasswordVerified = adminPWVerifiedState[0] == 0x01
                }
            }
        }
        else if characteristic.uuid.isEqual(USER_PASSWORD_VERIFIED_CHARACTERISTIC_UUID) {
            if let userPWVerifiedState = characteristic.value{
                if let data = deviceData {
                    data.userPasswordVerified = userPWVerifiedState[0] == 0x01
                }
            }
        }
        else if characteristic.uuid.isEqual(VERSION_CHARACTERISTIC_UUID) {
//            let nsdataStr = NSData.init(data: (characteristic.value)!)
//            print(nsdataStr)
            if let dd = characteristic.value {
                if let data = deviceData {
                    let version = String(data: dd, encoding: String.Encoding.ascii)!.filter{ !$0.isWhitespace }
                    print(version)
                    data.versionStr = version
                }
            }
        }
        else if characteristic.uuid.isEqual(FILTER1_NAME_CHARACTERISTIC_UUID)
        {
            if let dd = characteristic.value {
                if let data = deviceData {
                    let filterName = String(data: dd, encoding: String.Encoding.ascii)!
                    data.filterMonitors[0].filterName = filterName
                }
            }
        }
        else if characteristic.uuid.isEqual(FILTER2_NAME_CHARACTERISTIC_UUID)
        {
            if let dd = characteristic.value {
                if let data = deviceData {
                    let filterName = String(data: dd, encoding: String.Encoding.ascii)!
                    data.filterMonitors[1].filterName = filterName
                }
            }
        }
        else if characteristic.uuid.isEqual(FILTER3_NAME_CHARACTERISTIC_UUID)
        {
            if let dd = characteristic.value {
                if let data = deviceData {
                    let filterName = String(data: dd, encoding: String.Encoding.ascii)!
                    data.filterMonitors[2].filterName = filterName
                }
            }
        }
        else if characteristic.uuid.isEqual(GET_MOTOR_SETTINGS_CHARACTERISTIC_UUID){
            if let motorSettings = characteristic.value {
                if let data = deviceData {
                    // the rest of the settings are not used for now
                    data.RPMAlarmEnabled = ( motorSettings[0] & 0x08 ) != 0
                }
            }
        }
        else if characteristic.uuid.isEqual(ADMIN_PASSWORD_CHARACTERISTIC) {
            if let dd = characteristic.value {
                if let data = deviceData {
                    let adminPWStr = String(data: dd, encoding: String.Encoding.ascii)!
                    data.adminPassword = adminPWStr
                }
            }
                
            if let characteristic = userPasswordCharacteristic{
                peripheral.readValue(for: characteristic)
            }
        }
        else if characteristic.uuid.isEqual(USER_PASSWORD_CHARACTERISTIC) {
            if let dd = characteristic.value {
                if let data = deviceData {
                    let userPWStr = String(data: dd, encoding: String.Encoding.ascii)!
                    data.userPassword = userPWStr
                }
            }
        }
        else if characteristic.uuid.isEqual(RSSI_CHARACTERISTIC_UUID) {
            if let dd = characteristic.value {
                if let data = deviceData {
                    let temp = dd[0]
                    data.mobileRSSIinDevice = -(255 - Int(temp))
                }
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
        print(output)

        if let characteristic = flowIndexCharacteristic {
            let bytes: [UInt8] = [UInt8(output)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
        
        guard let data = deviceData else { return }
            output = Double(data.controlOutput)
    }
    
    func sendDeviceName(NewDeviceName newName: String )
    {
        print("The new name is \(newName)." )
        
        if let characteristic = writeDeviceNameThroughGATTCharacteristic {
            let bytes: [UInt8] = Array(newName.utf8)
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func enableUserPassword( enableState state: Bool )
    {
        var bytes: [UInt8] = [1]
        bytes[0] = state ? 1 : 0
        let data: NSData = NSData(bytes: bytes, length: bytes.count)
        if let peripheral = targetPeripheral {
            if let characteristic = enableUserPasswordCharacteristic {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func verifyUserPassword( UserPassword password: String )
    {
        print("Verify user assword \(password)." )
        
        if let characteristic = verifyUserPasswordCharacteristic {
            let bytes: [UInt8] = Array(password.utf8)
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func setUserPassword( UserPassword password: String )
    {
        print("set user assword \(password)." )
        
        if let characteristic = userPasswordCharacteristic {
            let bytes: [UInt8] = Array(password.utf8)
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func enableAdminPassword( enableState state: Bool )
    {
        var bytes: [UInt8] = [1]
        bytes[0] = state ? 1 : 0
        let data: NSData = NSData(bytes: bytes, length: bytes.count)
        if let peripheral = targetPeripheral {
            if let characteristic = enableAdminPasswordCharacteristic {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func verifyAdminPassword( AdminPassword password: String )
    {
        print("Verify admin assword \(password)." )
        
        if let characteristic = verifyAdminPasswordCharacteristic {
            let bytes: [UInt8] = Array(password.utf8)
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func setAdminPassword( AdminPassword password: String )
    {
        print("set admin assword \(password)." )
        
        if let characteristic = adminPasswordCharacteristic {
            let bytes: [UInt8] = Array(password.utf8)
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    // This function will first read the admin password.
    // after receiving the admin password in didUpdateValueFor delegate,
    // the admin password read handler in didUpdateValueFor delegate will
    // read the user password.
    func readPasswords()
    {
        if let peripheral = targetPeripheral {
            if let characteristic = adminPasswordCharacteristic{
                peripheral.readValue(for: characteristic)
            }
        }
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
    
    func readRSSI()
    {
        if let peripheral = targetPeripheral {
            peripheral.readRSSI()
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

extension Bool {

    var data:NSData {
        var _self = self
        return NSData(bytes: &_self, length: MemoryLayout.size(ofValue: self))
    }

    init?(data:NSData) {
        guard data.length == 1 else { return nil }
        var value = false
        data.getBytes(&value, length: MemoryLayout<Bool>.size)
        self = value
    }
}


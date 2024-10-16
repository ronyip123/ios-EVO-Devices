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
    
    enum DeiceListSortMode: Int
    {
        case eNone = 0
        case eAlphabeticalOrder = 1
        case eSignalStrength = 2
    }
    
    var isAliveListener : IsBLEConnectionAliveListener?
    var lostConnectionCount = 0
    
    //let GENERIC_ACCESS_SERVICE_UUID = CBUUID(string: "00001800-0000-1000-8000-00805f9b34fb");
    let GENERIC_ACCESS_SERVICE_UUID = CBUUID(string: "0x1800")
    let DEVICE_NAME_CHARACTERISTIC_UUID = CBUUID(string: "0x2A00")
    
    let MOTOR_CONTROL_SERVICE_UUID = CBUUID(string: "74b0d4c7-d0b4-4134-af7f-d92cb0a83b0d")
    let RPM_CHARACTERISTICS_UUID = CBUUID(string: "b1f8b319-fc1c-4756-a391-f56dfa101b24")
    let GO_CHARACTERISTIC_UUID = CBUUID(string: "02f2ec80-ce47-4383-9e41-170fc6fe06fe")
    let FLOW_INDEX_CHARACTERISTIC_UUID = CBUUID(string: "47844164-f734-40bd-8469-c38c02382046")
    let RPM_TYPE_CHARACTERISTIC_UUID = CBUUID(string:"081ed8c6-5d6b-4f29-b822-f53b3c961d8b")
    let OUTPUTTYPE_CHARACTERISTIC_UUID = CBUUID(string:"6071be7b-fb9b-40a0-bb58-0b8e7148623f")
    let PILOT_PULSE_CHARACTERISTIC_UUID = CBUUID(string:"89b2c276-c19f-4a68-bf7b-2d8dfb47c869")
    let GET_MOTOR_SETTINGS_CHARACTERISTIC_UUID = CBUUID(string: "28f4cdcd-5276-4f7c-afdb-16d613ab5e22")
    let RPM_ALARM_ENABLE_CHARACTERISTIC_UUID = CBUUID(string: "cb7d7295-f79e-4b5c-bda3-6209484d737d");
    let RPM_ALARM_HIGH_CHARACTERISTIC_UUID = CBUUID(string:"4795df00-c380-4242-bff3-eaea96684c76")
    let RPM_ALARM_LOW_CHARACTERISTIC_UUID = CBUUID(string:"fc3b7d82-4cc0-460f-bdea-d5da21ea3a37")
    let RPM_ALARM_STATUS_CHARACTERISTIC_UUID = CBUUID(string: "809f3fff-41bf-4c72-a6b0-fb88f4218bbe")
    let OUTPUT_LIMITS_CHARACTERISTIC_UUID = CBUUID(string:"42dbad3f-614c-41af-932c-a62a0bad46ed")
    
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
    
    let FILTER_MONITORING_SERVICE_UUID = CBUUID(string: "9f8d8050-9731-4597-85a0-d49fba2db671")
    let RESET_FILTER1_ALARM_CHARACTERISTIC_UUUID = CBUUID(string: "1aaf1b0e-b754-11eb-8529-0242ac130003")
    let RESET_FILTER2_ALARM_CHARACTERISTIC_UUID = CBUUID(string: "1aaf1dac-b754-11eb-8529-0242ac130003")
    let RESET_FILTER3_ALARM_CHARACTERISTIC_UUID = CBUUID(string: "1aaf1ea6-b754-11eb-8529-0242ac130003")
    let FILTER_MONITORING_ENABLE_STATUS_CHARACTERISTIC_UUID = CBUUID(string: "1aaf1f6e-b754-11eb-8529-0242ac130003")
    let REMAINING_FILTER_LIVES_CHARACTERISTIC_UUID = CBUUID(string: "1aaf24d2-b754-11eb-8529-0242ac130003")
    let FILTER1_NAME_CHARACTERISTIC_UUID = CBUUID(string: "8524b1f2-4ce9-466f-9886-238937741bf5")
    let FILTER2_NAME_CHARACTERISTIC_UUID = CBUUID(string: "ac2b933e-a782-4841-af93-377cdd6f521c");
    let FILTER3_NAME_CHARACTERISTIC_UUID = CBUUID(string: "d08c2d65-c3e1-464d-b2a5-8387959fe5de");
    
    let SILICON_LABS_OTA_SERVICE_UUID = CBUUID(string: "1D14D6EE-FD63-4FA1-BFA4-8F47B42119F0")
    
    let MOTOR_HISTORY_SERVICE_UUID = CBUUID(string: "8eb3afd9-2c75-462c-b02b-80c4082a460d")
    let MOTOR_HISTORY_SETTINGS_CHARACTERISTIC_UUID = CBUUID(string: "cf185d4b-b969-4f42-b65a-bdce81212962")
    let RESET_ACCUMULATED_REVOLUTIONS_CHARACTERISTIC_UUID = CBUUID(string: "0af5a0fd-ed46-4b8b-b6be-f3971deeac98")
    let RESET_ACCUMULATED_HOURS_CHARACTERISTIC_UUID = CBUUID(string: "5078ce48-8c61-4931-804f-6e35beec85a4")
    let ACCUMULATED_REVOLUTIONS_CHARACTERISTIC_UUID = CBUUID(string: "7486dd5e-bbad-4b9b-968f-c9bbd4aa5331")
    let ACCUMULATED_RUN_HOURS_CHARACTERISTIC_UUID = CBUUID(string: "2f87f7a2-7351-4436-8dfd-bd0ec8916ae5")
    
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
    var writeDeviceNameThroughGATTCharacteristic: CBCharacteristic?
    var verifyUserPasswordCharacteristic: CBCharacteristic?
    var verifyAdminPasswordCharacteristic: CBCharacteristic?
    var userPasswordCharacteristic: CBCharacteristic?
    var adminPasswordCharacteristic: CBCharacteristic?
    var enableUserPasswordCharacteristic: CBCharacteristic?
    var enableAdminPasswordCharacteristic: CBCharacteristic?
    var mobileRSSIinDeviceCharacteristic: CBCharacteristic?
    var getMotorSettingsCharacteristic: CBCharacteristic?
    var rpmTypeCharacteristic: CBCharacteristic?
    var outputTypeCharacteristic: CBCharacteristic?
    var pilotPulseCharacteristic: CBCharacteristic?
    var rpmAlarmHighCharacteristic:  CBCharacteristic?
    var rpmAlarmLowCharacteristic:  CBCharacteristic?
    var outputLimitsCharacteristic:  CBCharacteristic?
    var motorHistorySettingsCharacteristic: CBCharacteristic?
    var resetAccumulatedRevolutionCharacteristic: CBCharacteristic?
    var resetAccumulatedHoursCharacteristic: CBCharacteristic?
    var rpmAlarmEnabledCharacteristic: CBCharacteristic?
    var totalRevolutionCharacteristic: CBCharacteristic?
    var totalRunningHoursCharacteristic: CBCharacteristic?
    
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
            if ( rssi > -95 )
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
                    
                    if (rssi == 127)
                    {/*!
                      *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
                      *
                      *  @param central              The central manager providing this update.
                      *  @param peripheral           A <code>CBPeripheral</code> object.
                      *  @param advertisementData    A dictionary containing any advertisement and scan response data.
                      *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
                      * was not available.
                      *
                      *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
                      *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
                      *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
                      *
                      *  @seealso                    CBAdvertisementData.h
                      */
                        print("RSSI in \(DeviceName)is not available.")
                        return
                    }
                    
                    // bit 0 of dataArray[3] is RPM alarm status for all versions
                    // bit 1 is the filter monitor alarm for major version 3 and higher
                    // bit 2 and 3 are reserved for future use
                    // bit 4 to 7 are reserved for device type. 0 is ECM10-BTH1, the developement name for ECM-BCU.
                    
                    if dataArray[3] & 0xF0 == 0 { }  // detect device type. We only have one type for now
                    print("RSSI=\(RSSI)")
                    let newDevice = Device(id: peripheral.identifier, deviceRSSI: rssi, peripheral: peripheral, type: Int((dataArray[3] & 0xF0) >> 4), inAlarm: dataArray[3] & 0x03 != 0, deviceName: DeviceName)
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
            else if service.uuid.isEqual(FILTER_MONITORING_SERVICE_UUID) {
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
            else if service.uuid.isEqual(MOTOR_HISTORY_SERVICE_UUID) {
                print("Motor History Service found")
                peripheral.discoverCharacteristics(nil, for: service)
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
                        getMotorSettingsCharacteristic = characteristic
                        //Because the motor settings data are packed differently in version 4 and pre-version 4.
                        //Defer the reading of motor settings to after getting the version so we know how to unpack
                        //according to the version.
                        //peripheral.readValue(for: characteristic)
                    }
                    else if characteristic.uuid.isEqual(RPM_TYPE_CHARACTERISTIC_UUID)
                    {
                        print("found RPM Type characteristic")
                        rpmTypeCharacteristic = characteristic
                    }
                    else if characteristic.uuid.isEqual(OUTPUTTYPE_CHARACTERISTIC_UUID)
                    {
                        print("found output Type characteristic")
                        outputTypeCharacteristic = characteristic
                    }
                    else if characteristic.uuid.isEqual(PILOT_PULSE_CHARACTERISTIC_UUID)
                    {
                        print("found pilot pulse state characteristic")
                        pilotPulseCharacteristic = characteristic
                    }
                    else if characteristic.uuid.isEqual(OUTPUT_LIMITS_CHARACTERISTIC_UUID)
                    {
                        print("found output limits characteristic")
                        outputLimitsCharacteristic = characteristic
                    }
                    else if characteristic.uuid.isEqual(RPM_ALARM_ENABLE_CHARACTERISTIC_UUID)
                    {
                        print("found rpm alarm enabled characteristic")
                        rpmAlarmEnabledCharacteristic = characteristic
                    }
                    else if characteristic.uuid.isEqual(RPM_ALARM_HIGH_CHARACTERISTIC_UUID)
                    {
                        print("found high rpm alarm characteristic")
                        rpmAlarmHighCharacteristic = characteristic
                    }
                    else if characteristic.uuid.isEqual(RPM_ALARM_LOW_CHARACTERISTIC_UUID)
                    {
                        print("found low rpm alarm characteristic")
                        rpmAlarmLowCharacteristic = characteristic
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
        else if service.uuid.isEqual(FILTER_MONITORING_SERVICE_UUID) {
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
                    peripheral.readValue(for: characteristic) //This will trigger device to send version
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
        else if service.uuid.isEqual(MOTOR_HISTORY_SERVICE_UUID)
        {
            guard let characteristics = service.characteristics else { print("no motor history setting characteristics found"); return }
            
            for characteristic in characteristics {
                
                if characteristic.uuid.isEqual(MOTOR_HISTORY_SETTINGS_CHARACTERISTIC_UUID)
                {
                    motorHistorySettingsCharacteristic = characteristic
                    peripheral.readValue(for: characteristic)
                }
                else if characteristic.uuid.isEqual(RESET_ACCUMULATED_REVOLUTIONS_CHARACTERISTIC_UUID)
                {
                    resetAccumulatedRevolutionCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(RESET_ACCUMULATED_HOURS_CHARACTERISTIC_UUID)
                {
                    resetAccumulatedHoursCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(ACCUMULATED_REVOLUTIONS_CHARACTERISTIC_UUID )
                {
                    peripheral.setNotifyValue(true, for: characteristic)
                    totalRevolutionCharacteristic = characteristic
                }
                else if characteristic.uuid.isEqual(ACCUMULATED_RUN_HOURS_CHARACTERISTIC_UUID)
                {
                    peripheral.setNotifyValue(true, for: characteristic)
                    totalRunningHoursCharacteristic = characteristic
                }
            }
        }
    }
    
    //
    // delegate function to handle notification and read data from pheripheral
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
                    
                    if let characteristic = getMotorSettingsCharacteristic {
                        peripheral.readValue(for: characteristic)
                    }
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
                    if let majorVersion = data.getMajorVersion(){
                        if (majorVersion >= 4)
                        {
                            // version 4 and later
                            // the rest of the settings are not used for now
                            data.RPMAlarmEnabled = ( motorSettings[0] & DeviceData.RPM_ALARM_ENABLED_V4 ) != 0
                            // set RPM Type
                            data.setRPMType(value: (Int)((motorSettings[0] & DeviceData.RPM_TYPE_V4) >> 1))
                            data.setOutputType(value: Int((motorSettings[0] & DeviceData.PWM_OUTPUT_TYPE_V4)))
                            data.setPilotPulseState(value: (motorSettings[0] & DeviceData.PILOT_PULSE_ENABLE_V4) == 0 ? false : true )
                            data.motorSettingsEditable = ( motorSettings[0] & DeviceData.MOTOR_SETTINGS_EDITABLE_V4) != 0
                            data.highRPMAlarmLimit = (Int(motorSettings[3]) << 8) | Int(motorSettings[2])
                            data.lowRPMAlarmLimit = (Int(motorSettings[5]) << 8) | Int(motorSettings[4])
                            data.highOutputLimit = Int(motorSettings[6])
                            data.lowOutputLimit = Int(motorSettings[7])
                        }
                        else{
                            // version 3 and earlier version
                            // the rest of the settings are not used for now
                            data.RPMAlarmEnabled = ( motorSettings[0] & DeviceData.RPM_ALARM_ENABLED_PRE_V4 ) != 0
                            // Do not need to parse additional motor setting data.
                            // Motor settings is not available for firmware 3 and below
                        }
                    }
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
        else if characteristic.uuid.isEqual(MOTOR_HISTORY_SETTINGS_CHARACTERISTIC_UUID)
        {
            if let motorHistorySetttings = characteristic.value {
                if let data = deviceData {
                    if (motorHistorySetttings[0] & DeviceData.MOTOR_SENDS_RPM == 0)
                    {
                        data.setRPMType(value: DeviceData.PPT_NONE)
                    }
                    data.totalMotorRunningHoursEnable = ((motorHistorySetttings[0] & DeviceData.TOTAL_MOTOR_RUNTIME_ENABLE) != 0)
                    data.totalMotorRevolutionEanble = ((motorHistorySetttings[0] & DeviceData.TOTAL_MOTOR_REVOLUTION_ENABLE) != 0 )
                    data.motorHistorySettingsEditable = ((motorHistorySetttings[0] & DeviceData.MOTOR_HISTORY_SETTINGS_EDITABLE) != 0 )
                    
                    if (data.totalMotorRunningHoursEnable)
                    {
                        if let characteristic = totalRunningHoursCharacteristic {
                            peripheral.readValue(for: characteristic)
                        }
                    }
                    else if (data.totalMotorRevolutionEanble)
                    {
                        if let charcteristic = totalRevolutionCharacteristic {
                            peripheral.readValue(for: charcteristic)
                        }
                    }
                }
            }
        }
        else if characteristic.uuid.isEqual(ACCUMULATED_REVOLUTIONS_CHARACTERISTIC_UUID)
        {
            if let dataArray = characteristic.value {
                if let data = deviceData {
                    var temp: Int32
                    temp = Int32(dataArray[0] & 0xFF)
                    temp |= Int32((dataArray[1] & 0xFF) << 8)
                    temp |= Int32((dataArray[2] & 0xFF) << 16)
                    temp |= Int32((dataArray[3] & 0xFF) << 24)
                    
                    data.totalMotorRevolutions = temp
                }
            }
        }
        else if characteristic.uuid.isEqual(ACCUMULATED_RUN_HOURS_CHARACTERISTIC_UUID)
        {
            if let dataArray = characteristic.value {
                if let data = deviceData {
                    var temp: Int32
                    temp = Int32(dataArray[0] & 0xFF)
                    temp |= Int32((dataArray[1] & 0xFF) << 8)
                    temp |= Int32((dataArray[2] & 0xFF) << 16)
                    temp |= Int32((dataArray[3] & 0xFF) << 24)
                    
                    data.totalMotorRunningHours = temp
                }
            }
        }
    }
    
    //
    // delegate to receive the result after the peripheral tried to set a value for the characteristic.
    //
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        
        if (error == nil)
        {
            // write successfully
            if (characteristic.uuid.isEqual(RPM_TYPE_CHARACTERISTIC_UUID))
            {
                // update motor returns RPM flag to true after updated RPM Type. See sendRPMType
                guard let data = deviceData else { return }
                
                if let characteristic = motorHistorySettingsCharacteristic {
                    let b = data.getMotorHistorySettings() | DeviceData.MOTOR_SENDS_RPM
                    let bytes = [b]
                    let data: NSData = NSData(bytes: bytes, length: bytes.count)
                    if let peripheral = targetPeripheral {
                        peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
                    }
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
        
        guard let data = deviceData else { return }

        if let characteristic = flowIndexCharacteristic {
            let bytes: [UInt8] = [UInt8(output)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
        
        output = Double(data.controlOutput)
    }
    
    func sendRPMType()
    {
        guard let data = deviceData else { return }
        
        let type = data.getRPMType()
        
        if (type == -1 ) {return}
        
        if (type == DeviceData.PPT_NONE)
        {
            // selected none RPM Type, set the motor provides RPM feedback bit
            // in motor history settings to 0 (false)
            if let characteristic = motorHistorySettingsCharacteristic {
                let b = data.getMotorHistorySettings()
                let bytes = [b]
                let data: NSData = NSData(bytes: bytes, length: bytes.count)
                if let peripheral = targetPeripheral {
                    peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
                }
            }
        }
        else
        {
            // type = 0(36ppt), 1(18 ppt), 2(1 ppt)
            // After writing the RPM Type successfully, we also need to set the motor provides RPM feedback bit
            // in motor history settings to true
            if let characteristic = rpmTypeCharacteristic {
                let bytes = [UInt8(type)]
                let data: NSData = NSData(bytes: bytes, length: bytes.count)
                if let peripheral = targetPeripheral {
                    peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
                }
            }
        }
    }
    
    func sendOutputType()
    {
        guard let data = deviceData else { return }
        
        let type = data.getOutputType()
        
        if (type == -1 ) {return}
        
        if let characteristic = outputTypeCharacteristic {
            let bytes = [UInt8(type)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func sendPilotPulseState()
    {
        guard let data = deviceData else { return }
        
        let type = data.getPilotPulseState()
        
        if (type == -1 ) {return}
        
        if let characteristic = pilotPulseCharacteristic {
            let bytes = [UInt8(type)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func sendOutputLimits()
    {
        guard let data = deviceData else { return }
        
        if let characteristic = outputLimitsCharacteristic {
            let bytes = [UInt8(data.lowOutputLimit), UInt8(data.highOutputLimit)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func sendRPMALarmEnableStatus()
    {
        guard let data = deviceData else { return }
        
        if let characteristic = rpmAlarmEnabledCharacteristic {
            let bytes = [UInt8(data.RPMAlarmEnabled == true ? 1 : 0)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func sendRPMAlarmLowLimit()
    {
        guard let data = deviceData else { return }
        
        if let characteristic = rpmAlarmLowCharacteristic {
            let bytes = [UInt8((data.lowRPMAlarmLimit & 0xFF00) >> 8), UInt8(data.lowRPMAlarmLimit & 0x00FF)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func sendRPMAlarmHighLimit()
    {
        guard let data = deviceData else { return }
        
        if let characteristic = rpmAlarmHighCharacteristic {
            let bytes = [UInt8((data.highRPMAlarmLimit & 0xFF00) >> 8), UInt8(data.highRPMAlarmLimit & 0x00FF)]
            let data: NSData = NSData(bytes: bytes, length: bytes.count)
            if let peripheral = targetPeripheral {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
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
        let bytes: [UInt8] = [0] // The content of the write is not used
        let data: NSData = NSData(bytes: bytes, length: bytes.count)
        if let peripheral = targetPeripheral {
            if let characteristic = RPMAlarmStatusCharacteristic {
                peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func resetTotalRevolutionCounts()
    {
        let bytes: [UInt8] = [0] // The content of the write is not used
        let data: NSData = NSData(bytes: bytes, length: bytes.count)
        if let p = targetPeripheral {
            if let characteristic = resetAccumulatedRevolutionCharacteristic {
                p.writeValue(data as Data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func resetTotalRunningHours()
    {
        let bytes: [UInt8] = [0] // The content of the write is not used
        let data: NSData = NSData(bytes: bytes, length: bytes.count)
        if let p = targetPeripheral {
            if let characteristic = resetAccumulatedHoursCharacteristic {
                p.writeValue(data as Data, for: characteristic, type: .withResponse)
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
    
    func sort(sortMethod: DeiceListSortMode)
    {
        switch (sortMethod)
        {
            case .eNone:
                // do nothing
                break;
            case .eAlphabeticalOrder:
                print("sort by alphabetucal order")
                devices = devices.sorted{ $0.getNameString() < $1.getNameString() }
            case .eSignalStrength:
                print("sort by signal strength")
                devices = devices.sorted{$0.deviceRSSI > $1.deviceRSSI }
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


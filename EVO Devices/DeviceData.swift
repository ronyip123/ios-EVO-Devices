//
//  DeviceData.swift
//  EVO Devices
//
//  Created by Ronald Yip on 5/24/21.
//

import SwiftUI

class DeviceData: ObservableObject{
    
    static let PPT36: Int = 0
    static let PPT18: Int = 1
    static let PPT1:  Int = 2
    static let PPT_NONE: Int = 3
    
    static let OUTPUT_TYPE_PWM: Int = 0
    static let OUTPUT_TYPE_10V: Int = 1
    
    // motor history configuration bit assignment
    static let MOTOR_SENDS_RPM: UInt8 = 0x01
    static let TOTAL_MOTOR_RUNTIME_ENABLE: UInt8 = 0x02
    static let TOTAL_MOTOR_REVOLUTION_ENABLE: UInt8 = 0x04
    static let MOTOR_HISTORY_SETTINGS_EDITABLE: UInt8 = 0x08
    
    // pre-V4 motor settings bit assignmant
    static let RPM_ALARM_ENABLED_PRE_V4: UInt8 = 0x08
    
    // V4 motor settings bit assignment
    static let PWM_OUTPUT_TYPE_V4: UInt8 = 0x01
    static let RPM_TYPE_V4: UInt8 = 0x06
    static let PILOT_PULSE_ENABLE_V4: UInt8 = 0x08
    static let RPM_ALARM_ENABLED_V4: UInt8 = 0x10
    static let MOTOR_SETTINGS_EDITABLE_V4: UInt8 = 0x20
    
    
    static public let RPM_TYPES: [Int:String] = [0:"36 ppt", 1:"18 ppt", 2:"1 ppt", 3:"None"]
    static public let OUTPUT_TYPES: [String] = ["PWM", "0-10V"]
    static public let DISABLE_ENABLE_STATUS: [String] = ["Disable","Enable"]
    
    public var RPMTypeStrings: [String] = ["","","",""]
    
    @Published var RPM: Int
    @Published var type: String
    @Published var go: Bool
    var controlOutput: Int
    var versionStr: String
    var userPasswordEnabled: Bool
    var adminPasswordEnabled: Bool
    var userPasswordVerified: Bool
    var adminPasswordVerified: Bool
    var userPassword: String
    var adminPassword: String
    @Published var filterMonitors = [FilterMonitor(), FilterMonitor(), FilterMonitor()]
    let numberOfFilterMonitors = 3
    var PWEnableStatusReceived :Bool
    var deviceRSSIinMobile: Int
    var mobileRSSIinDevice: Int
    var RPMAlarmEnabled: Bool
    @Published var RPMInAlarm: Bool
    @Published var selectedRPMTypeString: String
    @Published var totalMotorRunningHours: Int32
    @Published var totalMotorRevolutions: Int32
    @Published var selectedOutputTypeString: String
    @Published var selectedPilotPulseStateString: String
    var motorSettingsEditable: Bool
    @Published var lowOutputLimit: Int
    @Published var highOutputLimit: Int
    @Published var lowRPMAlarmLimit: Int
    @Published var highRPMAlarmLimit: Int
    var totalMotorRunningHoursEnable: Bool
    var totalMotorRevolutionEanble: Bool
    var motorHistorySettingsEditable: Bool
    
    init() {
        self.RPM = 0
        self.type = ""
        self.go = false
        self.controlOutput = 0
        self.userPasswordEnabled = false
        self.adminPasswordEnabled = false
        self.userPasswordVerified = false
        self.adminPasswordVerified = false
        self.userPassword = ""
        self.adminPassword = ""
        self.RPMInAlarm = false
        self.versionStr = ""
        self.RPMAlarmEnabled = false
        self.PWEnableStatusReceived = false
        self.deviceRSSIinMobile = 0
        self.mobileRSSIinDevice = 0
        for t in DeviceData.RPM_TYPES
        {
            self.RPMTypeStrings[t.key] = t.value
        }
        self.selectedRPMTypeString = self.RPMTypeStrings[0]
        self.totalMotorRunningHours = 0
        self.totalMotorRevolutions = 0
        self.totalMotorRunningHoursEnable = false
        self.totalMotorRevolutionEanble = false
        self.motorHistorySettingsEditable = false
        self.selectedOutputTypeString = DeviceData.OUTPUT_TYPES[0]
        self.selectedPilotPulseStateString = DeviceData.DISABLE_ENABLE_STATUS[0]
        motorSettingsEditable = false
        self.lowOutputLimit = 0
        self.highOutputLimit = 100
        self.lowRPMAlarmLimit = 0
        self.highRPMAlarmLimit = 2000
    }
    
    func getGOString()->String{
        if go {
            return "Running"
        }
        else {
            return "Stop"
        }
    }
    
    func getSpeed()->Int{
        return controlOutput
    }
    
    func getMajorVersion()->Int?{
        if let index = versionStr.firstIndex(of: "."){
            let substring = versionStr[..<index] // major version characters
            print("Parsed substring \(substring)")
            if let intVal = Int(substring) {
                print("this is major version -> \(intVal)")
                return intVal
            }
        }
        print("Index not found")
        return nil
    }
    
    func displayMotorSettings() -> Bool{
        var enableDisplay = false
        if let version = getMajorVersion(){
            if (version >= 4){
                enableDisplay = true
            }
        }
        return enableDisplay;
    }
    
    func IsRPMOrFilterMonitoringEnabled() -> Bool {
        return RPMAlarmEnabled ||
            filterMonitors[0].filterEnabled ||
            filterMonitors[1].filterEnabled ||
            filterMonitors[2].filterEnabled
    }
    
    func UpdateDeviceRSSIinMobile( _ newRSSI: Int)
    {
        if ( deviceRSSIinMobile == 0 ){
            deviceRSSIinMobile = newRSSI
        }
        else {
            deviceRSSIinMobile = (deviceRSSIinMobile + newRSSI)/2
        }
    }
    
    func UpdateMobileRSSIinDevice( _ newRSSI: Int)
    {
        if ( mobileRSSIinDevice == 0 ){
            mobileRSSIinDevice = newRSSI
        }
        else {
            mobileRSSIinDevice = (mobileRSSIinDevice + newRSSI)/2
        }
    }
    
    func setRPMType(value:Int) {
        if (selectedRPMTypeString == DeviceData.RPM_TYPES[DeviceData.PPT_NONE])
        {
            return
        }
        
        if let s = DeviceData.RPM_TYPES[value]
        {
            selectedRPMTypeString = s
        }
    }
    
    // This function returns the rpm type
    // 0 = 36ppt, 1 = 28ppt, 2 = 1ppt and 3 = none
    // It retuns -1 in case of error
    func getRPMType()->Int{
        for t in DeviceData.RPM_TYPES {
            if ( t.value == selectedRPMTypeString)
            {
                return t.key
            }
        }
        
        return -1
    }
    
    func setOutputType(value:Int)
    {
        if (value > DeviceData.OUTPUT_TYPE_10V) {return}
        
        // value can only be 0 = PWM output or 1 = 0-10V output
        self.selectedOutputTypeString = DeviceData.OUTPUT_TYPES[value]
    }
    
    func getOutputType()->Int{
        if ( DeviceData.OUTPUT_TYPES[0] == self.selectedOutputTypeString) { return 0}
        if ( DeviceData.OUTPUT_TYPES[1] == self.selectedOutputTypeString) { return 1}
        return -1
    }
    
    func setPilotPulseState(value: Bool)
    {
        if (value)
            {self.selectedPilotPulseStateString = DeviceData.DISABLE_ENABLE_STATUS[1]}
        else
            {self.selectedPilotPulseStateString = DeviceData.DISABLE_ENABLE_STATUS[0]}
    }
    
    func getPilotPulseState()->Int
    {
        if ( DeviceData.DISABLE_ENABLE_STATUS[0] == self.selectedPilotPulseStateString) { return 0}
        if ( DeviceData.DISABLE_ENABLE_STATUS[1] == self.selectedPilotPulseStateString) { return 1}
        return -1
    }
    
    func getMotorHistorySettings() -> UInt8  {
    
        var b: UInt8 = 0
        
        if (totalMotorRevolutionEanble) {b |= DeviceData.TOTAL_MOTOR_REVOLUTION_ENABLE}
        if (totalMotorRunningHoursEnable) {b |= DeviceData.TOTAL_MOTOR_RUNTIME_ENABLE}
        if (motorHistorySettingsEditable) { b |= DeviceData.MOTOR_HISTORY_SETTINGS_EDITABLE}
        
        return b;
    }
}

enum FilterStatus
{
    case Normal
    case Dirty
    case Bad
}

class FilterMonitor
{
    var filterEnabled: Bool
    var filterRemainingLife: Int
    var filterName: String
    
    init(){
        self.filterEnabled = false
        self.filterRemainingLife = 100
        self.filterName = ""
    }
    
    func FilterAlarmStatus()->FilterStatus{
        if self.filterEnabled{
            if self.filterRemainingLife > 20 {
                return FilterStatus.Normal
            }
            else if self.filterRemainingLife > 0 {
                // remaining life > 0 but <= 20
                return FilterStatus.Dirty
            }
            else {
                // self.filterRemainingLife == 0
                return FilterStatus.Bad
            }
        }
        
        return FilterStatus.Normal
    }
}

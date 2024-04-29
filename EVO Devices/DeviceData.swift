//
//  DeviceData.swift
//  EVO Devices
//
//  Created by Ronald Yip on 5/24/21.
//

import SwiftUI

class DeviceData: ObservableObject{
    
    public enum RPMType: UInt8
    {
        case e36ppt
        case e18ppt
        case e1ppt
        case eNone
    }
    
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
    var RPMAlarmEnabled: Bool
    @Published var RPMInAlarm: Bool
    @Published var filterMonitors = [FilterMonitor(), FilterMonitor(), FilterMonitor()]
    let numberOfFilterMonitors = 3
    var PWEnableStatusReceived :Bool
    var deviceRSSIinMobile: Int
    var mobileRSSIinDevice: Int
    @Published var rpmType: RPMType
    
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
        self.rpmType = RPMType.e36ppt
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
    
    func getRPMType(value:UInt8) -> RPMType {
        switch (value)
        {
            case 0:
                return RPMType.e36ppt
            case 1:
                return RPMType.e18ppt
            case 2:
                return RPMType.e1ppt
            default:
                print("invalid RPM Type")
                return RPMType.eNone
        }
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

//
//  Device_Group.swift
//  EVO Devices
//
//  Created by Ronald Yip on 9/29/26.
//

import Foundation
class Device_Group : Codable, Identifiable, Hashable {
    static let NO_SIGNAL : Int8 = -100
    
    var devices : [Device]
    var groupName : String
    var groupID : UUID
    var groupFlowIndex : UInt8
    
    enum CodingKeys: String, CodingKey {
        case GroupID
        case DeviceArray
        case GroupName
        case GroupFlowIndex
    }
    
    static func == (lhs: Device_Group, rhs: Device_Group) -> Bool {
        return lhs.groupID == rhs.groupID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(groupID)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        groupID = try container.decode(UUID.self, forKey: .GroupID)
        groupName = try container.decode(String.self, forKey: .GroupName)
        devices = try container.decode([Device].self, forKey: .DeviceArray)
        groupFlowIndex = try container.decode(UInt8.self, forKey: .GroupFlowIndex)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(groupID, forKey: .GroupID)
        try container.encode(groupName, forKey: .GroupName)
        try container.encode(devices, forKey: .DeviceArray)
        try container.encode(groupFlowIndex, forKey: .GroupFlowIndex)
    }
    
    init(_ name: String) {
        self.groupName = name
        self.groupID = UUID()
        devices = []
        groupFlowIndex = 50
    }
    
    
    func reset_All_Devices_Before_Scanning(){
        for gd in devices
        {
            gd.deviceRSSI = Device_Group.NO_SIGNAL
            gd.flow_index_In_Advertisement = Device.NO_FLOW_INDEX_IN_ADVERTISEMENT
            gd.inRPMAlarm = false
            gd.inFilterAlarm = false
        }
    }
    
    func clearDeviceList() {
        devices = []
    }
    
    func getOffLineDeviceList() -> [Device] {
        var array : [Device] = []
        
        for gd in devices {
            if Device_Group.NO_SIGNAL == gd.deviceRSSI {
                array.append(gd)
            }
        }
        
        return array
    }
    
    func getDevice(_ index : Int) -> Device {
        return devices[index]
    }
    
    // find the first Device with the matching id.
    // if not found in the devices array, return nil
    func getDevice(_ id : UUID ) -> Device? {
        devices.first { $0.id == id }
    }
    
    func getNumberOdDevicesInTheGroup() -> Int {
        return devices.count
    }
    
    func addDeviceToGroup(_ device : Device ) {
        var newDevice = Device(device)
        devices.append(newDevice)
    }
    
    func getNumberOfOfflineDevices() -> Int {
        var count : Int = 0
        
        for gd in devices{
            if Device_Group.NO_SIGNAL == gd.deviceRSSI {
                count += 1
            }
        }
        
        return count
    }
    
    func getNumberOfAlarmDevices() -> Int {
        var count = 0
        
        for gd in devices {
            if gd.inFilterAlarm || gd.inRPMAlarm {
                count += 1
            }
        }
        
        return count
    }
    
    func setGroupFlowIndex(_ newFlowIndex : UInt8) {
        if newFlowIndex > 100 {
            return
        }
        
        groupFlowIndex = newFlowIndex
    }
}

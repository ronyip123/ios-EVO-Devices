//
//  Device.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI
import CoreBluetooth

class Device : Codable, Identifiable, Hashable{
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let NO_FLOW_INDEX_IN_ADVERTISEMENT : UInt8 = 127
    
    var id : UUID
    var deviceName: String?
    var deviceRSSI : Int8                   //runtime only
    var peripheral : CBPeripheral? = nil    //runtime only
    var type : UInt8                        //runtime only
    var inRPMAlarm : Bool                   //runtime only
    var inFilterAlarm : Bool                //runtime only
    var flow_index_In_Advertisement: UInt8  //runtime only
    
    enum CodingKeys: String, CodingKey {
        case DeviceID
        case DeviceName
    }
    
    init(_ ideviceName : String)
    {
        self.id = UUID()
        self.deviceName = ideviceName
        self.deviceRSSI = Device_Group.NO_SIGNAL
        self.type = 0
        self.flow_index_In_Advertisement =  Device.NO_FLOW_INDEX_IN_ADVERTISEMENT
        self.inRPMAlarm = false
        self.inFilterAlarm = false
    }
    
    init(_ iPeripheralID : UUID, _ iRSSI : Int8, _ iPeripheral : CBPeripheral, _ iType : UInt8, _ iRPMAlarm : Bool, _ iFilterAlarm : Bool, _ iName : String, _ iFlowIndex : UInt8 ){
        self.flow_index_In_Advertisement = iFlowIndex
        self.deviceName = iName
        self.inRPMAlarm = iRPMAlarm
        self.inFilterAlarm = iFilterAlarm
        self.type = iType;
        self.deviceRSSI = iRSSI
        self.id = iPeripheralID
        self.peripheral = iPeripheral
    }
    
    init(_ device : Device)
    {
        self.id = device.id
        self.deviceRSSI = device.deviceRSSI
        self.peripheral = device.peripheral
        self.type = device.type
        self.inRPMAlarm = device.inRPMAlarm
        self.inFilterAlarm = device.inFilterAlarm
        self.deviceName = device.deviceName
        self.flow_index_In_Advertisement = device.flow_index_In_Advertisement
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .DeviceID)
        self.deviceName = try container.decode(String.self, forKey: .DeviceName)

        self.peripheral = nil
        self.deviceRSSI = Device_Group.NO_SIGNAL
        self.type = 0
        self.inRPMAlarm = false;
        self.inFilterAlarm = false
        self.flow_index_In_Advertisement = Device.NO_FLOW_INDEX_IN_ADVERTISEMENT
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .DeviceID)
        try container.encode(deviceName, forKey: .DeviceName)
    }
    
    func getNameString() -> String {
        if let name = deviceName{
            return name
        }
        else {
            return "no name"
        }
    }
    
    func getTypeString() -> String {
        // We can get the device type bits from the advertisement.
        // This is the only type we have for now.
        if type == 0 {
            return "ECM_BCU"
        }
        else{
            return "Unkown Type"
        }
    }
    
    func getFlowIndexInAdvertisement() -> UInt8 {
        return flow_index_In_Advertisement;
    }
}



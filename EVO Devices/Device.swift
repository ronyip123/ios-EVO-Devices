//
//  Device.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI
import CoreBluetooth

struct Device : Identifiable, Hashable{
    
    static let NO_FLOW_INDEX_IN_ADVERTISEMENT : UInt8 = 127
    
    var id = UUID()
    var deviceRSSI : Int8
    var peripheral : CBPeripheral
    var type : UInt8
    var inAlarm : Bool
    var deviceName: String?
    var flow_index: UInt8
    
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
    
    func getFlowIndex() -> UInt8 {
        return flow_index;
    }
}



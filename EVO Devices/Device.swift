//
//  Device.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI
import CoreBluetooth

struct Device : Identifiable{
    var id : UUID
    var deviceRSSI : Int
    var peripheral : CBPeripheral
    var type : Int
    var inAlarm : Bool
    var deviceName: String?
    
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
}



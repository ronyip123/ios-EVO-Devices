//
//  Device_Group.swift
//  EVO Devices
//
//  Created by Ronald Yip on 9/29/26.
//

import Foundation
class Device_Group{
    static let NO_SIGNAL : Int8 = -100
    
    var devices : [Device]
    var name : String
    var ID :UUID
    var groupFlowIndex:UInt8
    
    init(name: String) {
        self.name = name
        self.ID = UUID()
        devices = []
        groupFlowIndex = 50
    }
    
    func reset_All_Devices_Before_Scanning(){
        for gd in devices
        {
            gd.deviceRSSI = Device_Group.NO_SIGNAL
            gd.flow_index = Device.NO_FLOW_INDEX_IN_ADVERTISEMENT
            
            
        }
    }
    
    
}

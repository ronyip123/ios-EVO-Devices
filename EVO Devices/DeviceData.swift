//
//  DeviceData.swift
//  EVO Devices
//
//  Created by Ronald Yip on 5/24/21.
//

import SwiftUI

class DeviceData: ObservableObject{
    @Published var RPM: Int
    @Published var type: String
    @Published var go: Bool
    @Published var speed: Int
    
    init() {
        self.RPM = 0
        self.type = ""
        self.go = false
        self.speed = 0
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
        return speed
    }
}

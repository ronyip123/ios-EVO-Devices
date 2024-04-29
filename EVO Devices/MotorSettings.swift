//
//  MotorSettings.swift
//  EVO Devices
//
//  Created by Ronald Yip on 6/12/21.
//

import SwiftUI

struct MotorSettings: View {
    
    @Binding var showViewState: Bool
    let targetDevice: Device
    @StateObject var store: DeviceStore
    @StateObject var data = DeviceData()
    let RPMTypes = ["36 ppt", "18 ppt", "1 ppt"]
    @State private var showRPMTypeDropDown = false
    @State private var selectedRPMType: String?
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    HStack{
                        Text("RPM Type:")
                            .padding()
                        
                    }
                    
                    HStack{
                        Text("Output Type:")
                            .padding()
                        
                    }
                    HStack{
                        Text("Pilot Pulse:")
                            .padding()
                    }
                    HStack{
                        Text("High Limit:")
                            .padding()
                    }
                    HStack{
                        Text("Low Limit:")
                            .padding()
                    }
                    HStack{
                        Text("RPM Alarm:")
                            .padding()
                    }
                    
                }
                .listStyle(SidebarListStyle())
                .navigationBarTitle(
                    "Motor Settings"
                )
            }
        }
        .onAppear(){
            print("MotorSettings appearing")
            store.setData(data)
        }
        .onDisappear(){
            print("MotorSettings disappearing")
            store.isAliveListener = nil
        }
    }
        
        
    
//    struct MotorSettings_Previews: PreviewProvider {
//        static var previews: some View {
//            MotorSettings()
//        }
//    }
}

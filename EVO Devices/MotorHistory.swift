//
//  MotorHistory.swift
//  EVO Devices
//
//  Created by Ronald Yip on 5/22/24.
//

import SwiftUI

struct MotorHistory: View {
    @Binding var showViewState: Bool
    @StateObject var store: DeviceStore
    @StateObject var data: DeviceData
    
    var body: some View {
        NavigationView{
            List{
                if (data.totalMotorRunningHoursEnable){
                    VStack{
                        HStack{
                            Text("Run Hours:")
                            Text("\(data.totalMotorRunningHours) hours").padding()
                        }
                        Button(action:{
                            store.resetTotalRunningHours()
                        })
                        {
                            Text("Reset")
                            Image(systemName: (data.adminPasswordEnabled && !data.adminPasswordVerified) ?  "lock" : "lock.open")
                        }
                        .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                        .disabled(!data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                    }
                    .padding()
                }
                
                if (data.totalMotorRevolutionEanble){
                    VStack{
                        HStack{
                            Text("Revolutions:")
                            Text("\(data.totalMotorRevolutions) K").padding()
                        }
                        Button(action:{
                            store.resetTotalRevolutionCounts()
                        })
                        {
                            Text("Reset")
                            Image(systemName: (data.adminPasswordEnabled && !data.adminPasswordVerified) ?  "lock" : "lock.open")
                        }
                        .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                        .disabled(!data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                    }
                    .padding()
                }
            }
            .listStyle(SidebarListStyle())
            .navigationBarTitle("Motor History")
        }
        .onAppear(){
            print("MotorHistory appearing")
        }
        .onDisappear(){
            print("MotorHistory disappearing")
            //store.isAliveListener = nil
        }
    }
}

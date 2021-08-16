//
//  StatusDetails.swift
//  EVO Devices
//
//  Created by Ronald Yip on 6/12/21.
//

import SwiftUI

struct StatusDetails: View {
    @ObservedObject var data: DeviceData
    @ObservedObject var store: DeviceStore
    @Binding var showViewState: Bool
    @State var RPMAlarmEnabled: Bool
    @State var filter1Enabled: Bool
    @State var filter2Enabled: Bool
    @State var filter3Enabled: Bool
    @State var filterMonitoringEnabled: Bool

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView{
            ZStack{
            List{
//                if self.$RPMAlarmEnabled.wrappedValue {
                if self.RPMAlarmEnabled {
                    HStack{
                        Text("RPM Alarm:").padding()
                        if data.RPMInAlarm {
                            // to be replaced by the red LED
                            Image("RedLED")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
                        }
                        else {
                            // to be replaced by the green LED
                            Image("GreenLED")
//                              .resizable()
//                              .aspectRatio(contentMode: .fit)
                        }
                        Button(action: {
                            // reset rpm alarm
                            store.resetRPMAlarm()
                        }){
                            HStack{
                                Text("Reset Alarm")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                                Image(systemName: !data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified) ? "lock" : "lock.open")
                            }
                        }
                        .buttonStyle(RoundedRectangleButtonStyle())
                        .disabled(!data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified))
                    }
                }

//                if self.$filterMonitoringEnabled.wrappedValue {
                if self.filterMonitoringEnabled {
                    Text("Filter Monitors:")
                        .padding()
                    
//                    if self.$filter1Enabled.wrappedValue {
                    if self.filter1Enabled {
                        HStack{
                            if data.filterMonitors[0].filterName.count != 0 {
                                Text(data.filterMonitors[0].filterName)
                            }
                            else {
                                Text("Filter1")
                            }
                    
                            Text("\(data.filterMonitors[0].filterRemainingLife) %")
                            // The following Filter Status are to be replaced by images
                            switch data.filterMonitors[0].FilterAlarmStatus(){
                                case FilterStatus.Normal:
                                    Image("NormalFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case FilterStatus.Dirty:
                                    Image("DirtyFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case FilterStatus.Bad:
                                    Image("BadFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                            }
                            Button( action: { store.resetFilter(FilterIndes: 0 )}){
                                HStack{
                                    Text("Reset")
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                    Image(systemName: !data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified) ? "lock" : "lock.open")
                                }
                            }
                            .buttonStyle(RoundedRectangleButtonStyle())
                            .disabled(!data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified))
                        }
                    }
                
//                    if self.$filter2Enabled.wrappedValue {
                    if self.filter2Enabled {
                        HStack{
                            if data.filterMonitors[1].filterName.count != 0 {
                                Text(data.filterMonitors[1].filterName)
                            }
                            else {
                                Text("Filter2")
                            }
                            Text("\(data.filterMonitors[1].filterRemainingLife) %")
                            // The following Filter Status are to be replaced by images
                            switch data.filterMonitors[1].FilterAlarmStatus(){
                                case FilterStatus.Normal:
                                    Image("NormalFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case FilterStatus.Dirty:
                                    Image("DirtyFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case FilterStatus.Bad:
                                    Image("BadFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                            }
                            Button( action: { store.resetFilter(FilterIndes: 1) }){
                                HStack{
                                    Text("Reset")
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                    Image(systemName: !data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified) ? "lock" : "lock.open")
                                }
                            }
                            .buttonStyle(RoundedRectangleButtonStyle())
                            .disabled(!data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified))
                        }
                    }
                
//                    if self.$filter2Enabled.wrappedValue {
                    if self.filter3Enabled {
                        HStack{
                            if data.filterMonitors[2].filterName.count != 0 {
                                Text(data.filterMonitors[2].filterName)
                            }
                            else {
                                Text("Filter3")
                            }
                            Text("\(data.filterMonitors[2].filterRemainingLife) %")
                            // The following Filter Status are to be replaced by images
                            switch data.filterMonitors[2].FilterAlarmStatus(){
                                case FilterStatus.Normal:
                                    Image("NormalFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case FilterStatus.Dirty:
                                    Image("DirtyFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case FilterStatus.Bad:
                                    Image("BadFilter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                            }
                            Button( action: { store.resetFilter(FilterIndes: 2)}){
                                HStack{
                                    Text("Reset")
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                    Image(systemName: !data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified) ? "lock" : "lock.open")
                                }
                            }
                            .buttonStyle(RoundedRectangleButtonStyle())
                            .disabled(!data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified))
                        }
                    }
                }
                
                Button( action:{showViewState.toggle()}){
                    Text("Done")
                        .padding()
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
                .buttonStyle(RoundedRectangleButtonStyle())
            }
            .navigationBarTitle("Status Details")
             
            }
        }
        .onAppear(){
        
        }
        .onDisappear(){
            
        }
    }
}

//struct StatusDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        StatusDetails(data: DeviceData(), store: DeviceStore(), showViewState: false)
//    }
//}

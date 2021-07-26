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
    @State var RPMAlarmEnabled = false
    @State var filter1Enabled = false
    @State var filter2Enabled = false
    @State var filter3Enabled = false
    @State var filterMonitoringEnabled = false
    @State var initializing = true;
    
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
                            Text("Reset Alarm")
                                .foregroundColor(colorScheme == .light ? .black : .white)
                        }
                        .buttonStyle(RoundedRectangleButtonStyle())
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
                                Text(data.filterMonitors[0].filterName).padding()
                            }
                            else {
                                Text("Filter1").padding()
                            }
                    
                            Text("\(data.filterMonitors[0].filterRemainingLife) %").padding()
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
                                Text("Reset")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }
                            .buttonStyle(RoundedRectangleButtonStyle())
                        }
                    }
                
//                    if self.$filter2Enabled.wrappedValue {
                    if self.filter2Enabled {
                        HStack{
                            if data.filterMonitors[1].filterName.count != 0 {
                                Text(data.filterMonitors[1].filterName).padding()
                            }
                            else {
                                Text("Filter2").padding()
                            }
                            Text("\(data.filterMonitors[1].filterRemainingLife) %").padding()
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
                                Text("Reset")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }
                            .buttonStyle(RoundedRectangleButtonStyle())
                        }
                    }
                
//                    if self.$filter2Enabled.wrappedValue {
                    if self.filter3Enabled {
                        HStack{
                            if data.filterMonitors[2].filterName.count != 0 {
                                Text(data.filterMonitors[2].filterName).padding()
                            }
                            else {
                                Text("Filter3").padding()
                            }
                            Text("\(data.filterMonitors[2].filterRemainingLife) %").padding()
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
                                Text("Reset")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }
                            .buttonStyle(RoundedRectangleButtonStyle())
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
             
                if self.initializing {
                     ProgressView()
                    .accentColor(Color.green)
                    .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                }
            }
        }
        .onAppear(){
            //store.getFilterEnableStatus()
            RPMAlarmEnabled = data.RPMAlarmEnabled
            filter1Enabled = data.filterMonitors[0].filterEnabled
            filter2Enabled = data.filterMonitors[1].filterEnabled
            filter3Enabled = data.filterMonitors[2].filterEnabled
            filterMonitoringEnabled = filter1Enabled || filter2Enabled || filter3Enabled
            
            self.initializing = false
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

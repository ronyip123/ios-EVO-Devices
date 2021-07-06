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
    
    var body: some View {
        NavigationView{
            List{
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
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
                    }
                    Button(action: {
                        // reset rpm alarm
                        store.resetRPMAlarm()
                    }){
                        Text("Reset Alarm")
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                }
                
                Text("Filter Monitors:")
                    .padding()
                
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
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                }
                
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
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                }
                
                HStack{
                    if data.filterMonitors[2].filterName.count != 0 {
                        Text(data.filterMonitors[2].filterName).padding()
                    }
                    else {
                        Text("Filter2").padding()
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
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                }
                
                Button( action:{showViewState.toggle()}){
                    Text("Done")
                        .padding()
                }
                .buttonStyle(RoundedRectangleButtonStyle())
                
            }
            .navigationBarTitle("Status Details")
        }
        .onAppear(){
            //store.getFilterEnableStatus()
             
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

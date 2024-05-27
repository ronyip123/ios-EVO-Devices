//
//  MotorSettings.swift
//  EVO Devices
//
//  Created by Ronald Yip on 6/12/21.
//

import SwiftUI

struct MotorSettings: View {
    
    @Binding var showViewState: Bool
    @StateObject var store: DeviceStore
    @StateObject var data: DeviceData
    @State var RPMEnableString: String
    @State var highlimit: Int
    @State var lowlimit: Int
    @State var highRPMAlarm: Int
    @State var lowRPMAlarm: Int
    
    var body: some View {
        NavigationView{
            VStack{
                if (data.motorSettingsEditable == false){
                    Text("View Only")
                }
                List{
                    VStack{
                        Text("RPM Type:")
                            .padding() //leading pad
                        
                        Picker(selection: $data.selectedRPMTypeString, label: Text("RPM Type:")) {
                            ForEach(data.RPMTypeStrings, id: \.self) {
                                Text($0)
                                    .fontWeight(.bold)
                                    .font(.title2)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: data.selectedRPMTypeString, perform: { value in
                            store.sendRPMType()
                        })
                    }
                    .disabled(data.motorSettingsEditable == false || !data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                    
                    VStack{
                        Text("Output Type:")
                            .padding() //leading pad
                        
                        Picker(selection: $data.selectedOutputTypeString, label: Text("Output Type:")) {
                            ForEach(DeviceData.OUTPUT_TYPES, id: \.self) {
                                Text($0)
                                    .fontWeight(.bold)
                                    .font(.title2)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: data.selectedOutputTypeString, perform: { value in
                            store.sendOutputType()
                        })
                        
                    }
                    .disabled(data.motorSettingsEditable == false || !data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                    
                    VStack{
                        Text("Pilot Pulse:")
                            .padding() //leading pad
                        
                        Picker(selection: $data.selectedPilotPulseStateString, label: Text("Pilot Pulse:")) {
                            ForEach(DeviceData.DISABLE_ENABLE_STATUS, id: \.self) {
                                Text($0)
                                    .fontWeight(.bold)
                                    .font(.title2)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: data.selectedPilotPulseStateString, perform: { value in
                            store.sendPilotPulseState()
                        })
                    }
                    .disabled(data.motorSettingsEditable == false || !data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                    
                    VStack{  //high and low limits
                        HStack{
                            Text("High Limit:")
                                .padding()
                            
                            TextField("between low limit and 100", value: $highlimit, format: .number )
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            Text("%")
                            Button(action: {
                                data.highOutputLimit = highlimit
                                store.sendOutputLimits()
                            })
                            {
                                Image(systemName: "paperplane.fill")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            //.disabled(data.highOutputLimit == highlimit )
                            .disabled(data.highOutputLimit == highlimit || highlimit > 100 || highlimit <= data.lowOutputLimit )
                        }
                        
                        HStack{
                            Text("Low Limit:")
                                .padding()
                            
                            TextField("between 0 and high limit", value: $lowlimit, format: .number )
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            Text("%")
                            Button(action: {
                                data.lowOutputLimit = lowlimit
                                store.sendOutputLimits()
                            })
                            {
                                Image(systemName: "paperplane.fill")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .disabled(lowlimit == data.lowOutputLimit || lowlimit < 0 || lowlimit >= data.highOutputLimit )
                        }
                    }
                    .disabled(data.motorSettingsEditable == false || !data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                    
                    VStack{
                        VStack{
                            Text("RPM Alarm:")
                                .padding()
                            
                            Picker(selection: $RPMEnableString, label: Text("RPM Alarm:")) {
                                ForEach(DeviceData.DISABLE_ENABLE_STATUS, id: \.self) {
                                    Text($0)
                                        .fontWeight(.bold)
                                        .font(.title2)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: RPMEnableString, perform: { value in
                                data.RPMAlarmEnabled = value == DeviceData.DISABLE_ENABLE_STATUS[0] ? false : true
                                store.sendRPMALarmEnableStatus()
                            })
                        }

                        if ( data.RPMAlarmEnabled )
                        {
                            HStack{
                                Text("Alarm High:")
                                    .padding()
                                
                                TextField("between low alarm and 2000", value: $highRPMAlarm, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                Text("rpm")
                                Button(action: {
                                    data.highRPMAlarmLimit = highRPMAlarm
                                    store.sendRPMAlarmHighLimit()
                                })
                                {
                                    Image(systemName: "paperplane.fill")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(highRPMAlarm == data.highRPMAlarmLimit || highRPMAlarm <= data.lowRPMAlarmLimit || highRPMAlarm > 2000 )
                            }
                            
                            HStack{
                                Text("Alarm Low:")
                                    .padding()
                                
                                TextField("between 0 and high alarm", value: $lowRPMAlarm, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                Text("rpm")
                                Button(action: {
                                    data.lowRPMAlarmLimit = lowRPMAlarm
                                    store.sendRPMAlarmLowLimit()
                                })
                                {
                                    Image(systemName: "paperplane.fill")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(lowRPMAlarm == data.lowRPMAlarmLimit || lowRPMAlarm >= data.highRPMAlarmLimit || lowRPMAlarm < 0)
                            }
                        }
                    }
                    .disabled(data.motorSettingsEditable == false || !data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                }
                // do not disable the whole list if the conditions do not match because if disabled, the list cannot be scrolled.
                //.disabled(data.motorSettingsEditable == false || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                .listStyle(SidebarListStyle())
                .navigationBarTitle("Motor Settings")
                
            }
        }
        .onAppear(){
            print("MotorSettings appearing")
        }
        .onDisappear(){
            print("MotorSettings disappearing")
            //store.isAliveListener = nil
        }
    }

//    func UpdateRPMTypeChanged(){
//        
//        store.sendRPMType()
//    }
//    struct MotorSettings_Previews: PreviewProvider {
//        static var previews: some View {
//            MotorSettings()
//        }
//    }
}


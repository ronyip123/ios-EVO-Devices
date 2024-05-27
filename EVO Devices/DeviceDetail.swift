//
//  DeviceDetail.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI
import CoreBluetooth

struct DeviceDetail: View, IsBLEConnectionAliveListener {
   
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let targetDevice: Device
    @State var deviceNameStr: String
    @StateObject var store: DeviceStore
    @StateObject var data = DeviceData()
    @State private var connected = false
    //@State var showSecuritySettingsView = false  // not used yet
    @State var showStatusDetailsView = false
    @State var showPasswordView = false
    @State var threeSecTimer: Timer? = nil
    @State var inAlarm = false
    @State var hideStatusDetails = true
    @State var showSetPassword = false
    @State var showMotorSettings = false
    @State var showMotorHistory = false

    var uiDevice = UIDevice.current.userInterfaceIdiom
    
    var body: some View {
        
        VStack{
            List{
                HStack{
                    Text("Device Type:").font(.subheadline)
                    Text(targetDevice.getTypeString())
                        .fontWeight(.bold)
                        .font(.title2)
                    Text("V\(data.versionStr)")
                        .alignmentGuide(.leading) { d in d[.trailing] }
                }.padding()
                HStack{
                    Text("Device Name:").font(.subheadline)
                    TextField("", text: $deviceNameStr, onCommit: {
                        deviceNameChanged(deviceNameStr)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(Font.title2.weight(.heavy))
                    .disabled(!data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified))
                    Image(systemName: !data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified) ? "lock" : "lock.open")
                }.padding()
                
                HStack{
                    Text("RPM:").font(.subheadline)
                    Text("\(data.RPM)")
                        .fontWeight(.bold)
                        .font(.title2)
                }.padding()
                
                HStack{
                    Text("Motor Status: ").font(.subheadline)
                    Text(data.getGOString())
                        .fontWeight(.bold)
                        .font(.title2)
                }.padding()
                
                VStack{
                    HStack{
                        Text("Motor Speed:").font(.subheadline)
                        Text("\(store.output, specifier: "%g") %")
                            .fontWeight(.bold)
                            .font(.title2)
                        Image(systemName: !data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified) ? "lock" : "lock.open")
                    }
                    
                    HStack{
                        Button(action: {
                            // launch sort options dialog
                            print("decrement output by 1 %.")
                            if (store.output > 0)
                            {
                                store.output -= 1;
                                FlowIndexChanged()
                            }
                        })
                        {
                            Image(systemName: "minus")
                        }
                        .buttonStyle(BorderlessButtonStyle()) // to avoid tap button in HStack activating all button actions
                        //See https://www.hackingwithswift.com/forums/swiftui/tap-button-in-hstack-activates-all-button-actions-ios-14-swiftui-2/2952
                                                                
                        Slider(value: $store.output, in: 0...100, step: 1 ){
                            editing in if !editing {
                                FlowIndexChanged()
                            }
                        }
//                        .padding()
//                        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                                                                
                        Button(action: {
                            // launch sort options dialog
                            print("increment output by 1 %.")
                            if (store.output < 100)
                            {
                                store.output += 1;
                                FlowIndexChanged()
                            }
                        })
                        {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(BorderlessButtonStyle()) // to avoid tap button in HStack activating all button actions
                    }
                    .accentColor(Color.green)
                    .disabled(!data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified))
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                    .padding()
                }.padding()
                
                Button(action: {
                        self.showPasswordView.toggle()
                }){
                    Text("Unlock")
                        .padding()
                        .font(.title)
                }
                // disable Unlock button if user and admin passwords are not used or already verified
                .disabled(!data.PWEnableStatusReceived || (!data.adminPasswordEnabled || data.adminPasswordVerified) && (!data.userPasswordEnabled || data.userPasswordVerified))
                .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                .sheet(isPresented: $showPasswordView, content: {
                    Password(showViewState: $showPasswordView, store: store, mode: PassWordViewMode.eVerify, data: data)
                      //  .animation(.spring())
                        .transition(.slide)
                })
                
                if !self.$hideStatusDetails.wrappedValue {
                    Button(action: {
                        // set flag to show status details view
                        self.showStatusDetailsView.toggle()
                    }){
                        Text("Status Details")
                            .padding()
                            .background( inAlarm ? Color.red : Color.green )
                            //.foregroundColor(.white)
                            .font(.title)
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(alarmstate: inAlarm))
                    .sheet(isPresented: $showStatusDetailsView, content: {
                        StatusDetails(data: self.data, store: self.store, showViewState: $showStatusDetailsView, RPMAlarmEnabled: data.RPMAlarmEnabled, filter1Enabled: data.filterMonitors[0].filterEnabled, filter2Enabled: data.filterMonitors[1].filterEnabled, filter3Enabled: data.filterMonitors[2].filterEnabled, filterMonitoringEnabled: data.filterMonitors[0].filterEnabled || data.filterMonitors[1].filterEnabled || data.filterMonitors[2].filterEnabled  )
                        //            .animation(.spring())
                                    .transition(.slide)
                    })
                }
                
                if (data.totalMotorRevolutionEanble || data.totalMotorRunningHoursEnable)
                {
                    Button(action: {
                        // set flag to show motor history view
                        self.showMotorHistory.toggle()
                    }){
                        Text("Motor History")
                            .padding()
                            .font(.title)
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
//                    .sheet(isPresented: $showStatusDetailsView, content: {
//                        StatusDetails(data: self.data, store: self.store, showViewState: $showStatusDetailsView, RPMAlarmEnabled: data.RPMAlarmEnabled, filter1Enabled: data.filterMonitors[0].filterEnabled, filter2Enabled: data.filterMonitors[1].filterEnabled, filter3Enabled: data.filterMonitors[2].filterEnabled, filterMonitoringEnabled: data.filterMonitors[0].filterEnabled || data.filterMonitors[1].filterEnabled || data.filterMonitors[2].filterEnabled  )
//                        //            .animation(.spring())
//                                    .transition(.slide)
//                    })
                }
                
                VStack(alignment: .leading){
                    Text("Device RSSI: \(data.mobileRSSIinDevice) dBm")
                        .font(.subheadline)
                
                    HStack{
                        Text("Mobile RSSI: \(data.deviceRSSIinMobile) dBm").font(.subheadline)
                        if data.deviceRSSIinMobile >= -85 {
                            Text("Strong")
                                .font(.subheadline)
                                .foregroundColor(.init(red: 0x00, green: 0x53, blue: 0x00))
                        }
                        else if data.deviceRSSIinMobile >= -92 {
                            Text("Good")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        else {
                            Text("Weak")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }
                    
                if self.uiDevice == .pad {

                    Button(action: {
                        //store.isAliveListener = nil
                        store.disconnect(targetPeripheral: targetDevice.peripheral)
                        //oneSecTimer?.invalidate()
                    }) {
                        Text("Disconnect")
                            .padding()
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))

                }
//                    Button(action: {
//                        // switch to motor setting user interface
//                    }){
//                        Text("Motor Settings")
//                    }
//                    .buttonStyle(RoundedRectangleButtonStyle())
//                    Button(action: {
//                        // set flag to show security settings view
//                        self.showSecuritySettingsView.toggle()
//                    }){
//                        Text("Security Settings")
//                    }
//                    .buttonStyle(RoundedRectangleButtonStyle())
//                    .sheet(isPresented: $showSecuritySettingsView, content: {
////                        SecuritySettings(userPassword: data.userPassword, adminPassword: data.adminPassword, userPasswordEnableState: data.userPasswordEnabled, adminPasswordEnableState: data.adminPasswordEnabled, showViewState: self.$showSecuritySettingsView)
//                        SecuritySettings(data: self.data, store: self.store, showViewState: self.$showSecuritySettingsView)
//                                .animation(.spring())
//                                .transition(.slide)
//                    })
                
            }
            .navigationBarTitle("Device Detail")
            .navigationBarItems(trailing: Menu {
                Button ( action: {
                    if data.PWEnableStatusReceived && (!data.adminPasswordEnabled || data.adminPasswordVerified) {
                        self.showSetPassword.toggle()
                    }
                }){
                    HStack{
                        Text("Security Settings")
                        Image(systemName: !data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified) ? "lock" : "lock.open")
                    }
                }
                .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                
                if let v = data.getMajorVersion() {
                    if ( v >= 4)
                    {
                        Button ( action: {
                            self.showMotorSettings.toggle()
                        }){
                            HStack{
                                Text("Motor Settings")
                                Image(systemName: "gear")
                            }
                        }
                        .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                    }
                }
            } label: {
                HStack{
                    Text("Settings")
                    Image(systemName: "gear")
                }

            })
            .sheet(isPresented: $showSetPassword, content: {
                Password(showViewState: $showSetPassword, store: store, mode: PassWordViewMode.eEdit, data: data)
                  //  .animation(.spring())
                    .transition(.slide)
            })
            .sheet(isPresented: $showMotorSettings, content: {
                MotorSettings(showViewState: $showMotorSettings, store: self.store, data: self.data, RPMEnableString: data.RPMAlarmEnabled == true ? DeviceData.DISABLE_ENABLE_STATUS[1] : DeviceData.DISABLE_ENABLE_STATUS[0], highlimit: data.highOutputLimit, lowlimit: data.lowOutputLimit, highRPMAlarm: data.highRPMAlarmLimit, lowRPMAlarm: data.lowRPMAlarmLimit )
                  //  .animation(.spring())
                    .transition(.slide)
            })
            .sheet(isPresented: $showMotorHistory, content: {
                MotorHistory(showViewState: $showMotorHistory, store: self.store, data: self.data )
                    .transition(.slide)
            })
            
            
            
//            .navigationBarItems(trailing:
//                Button ( action: {
//                    if data.PWEnableStatusReceived && (!data.adminPasswordEnabled || data.adminPasswordVerified) {
//                        self.showSetPassword.toggle()
//                    }
//                }){
//                    HStack{
//                        Text("Security")
//                        Image(systemName: !data.PWEnableStatusReceived || (data.adminPasswordEnabled && !data.adminPasswordVerified) ? "lock" : "lock.open")
//                    }
//                }
//            )
//            .sheet(isPresented: $showSetPassword, content: {
//                Password(showViewState: $showSetPassword, store: store, mode: PassWordViewMode.eEdit, data: data)
//                //    .animation(.spring())
//                    .transition(.slide)
//            })
            
        }
        .onAppear(){
            print("DeviceDetail appearing")
            store.isAliveListener = self
            data.PWEnableStatusReceived = false
            // we know the blutooth is already running since the user was able to scan bluetooth  // devices and select from the device list connect to device.
            //store.connect(targetPeripheral: targetDevice.peripheral) //moved to ContentView when the device is tapped in the device list
            store.setData(data)
            startThreeSecTimer()
        }
        .onDisappear(){
            print("DeviceDetail disappearing")
            store.isAliveListener = nil
            if self.uiDevice == .phone {
                store.disconnect(targetPeripheral: targetDevice.peripheral)
            }
            threeSecTimer?.invalidate()
        }
    }
    
    func FlowIndexChanged(){
        store.sendFlowIndex()
    }
    
    func deviceNameChanged(_ newName: String){
        store.sendDeviceName(NewDeviceName: newName)
    }
    
    func startThreeSecTimer()
    {
        threeSecTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true){ _ in
              inAlarm = data.RPMInAlarm ||
                data.filterMonitors[0].FilterAlarmStatus() == FilterStatus.Bad ||
                data.filterMonitors[1].FilterAlarmStatus() == FilterStatus.Bad ||
                data.filterMonitors[2].FilterAlarmStatus() == FilterStatus.Bad
            
            var version3AndHigher = false
            if let version = data.getMajorVersion() {
                if version >= 3 { version3AndHigher = true }
            }

            hideStatusDetails = !(data.IsRPMOrFilterMonitoringEnabled() && version3AndHigher)
            
            if uiDevice == .phone {
                store.isBLEConectionStillAlive()
            }
            
            store.readRSSI()
        }
    }
    
    // Implement IsBLEConnectionAliveListener protocol functions
    func bluetoothLost() {
       // handle bluetoothLost
        print("Lost BLE conneciton")
        self.showStatusDetailsView = false
        self.showPasswordView = false
        self.showSetPassword = false
        presentationMode.wrappedValue.dismiss()
    }
}

#if canImport(UIKit)
extension View{
    // we need this funciton because SwiftUI does not have a easy way to hide the keyboard
    // after it is activated. This function is called after the keyboard is activated by the device name TextEditor.
    // It asks UIKit to search through what’s called the responder chain – the collection of controls that are
    // currently responding to user input – and find one that is capable of resigning its first responder status.
    // That’s a fancy way of saying “ask whatever has control to stop using the keyboard”, which in our case means
    // the keyboard will be dismissed when a text field is active.
    func hidekeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


struct RoundedRectangleButtonStyle: ButtonStyle {
    var alarmstate: Bool
    func makeBody(configuration: Configuration) -> some View {
        Button(action:{}, label: {
            HStack{
               // Spacer()
                configuration.label.foregroundColor(.white)
               // Spacer()
            }
            .background(alarmstate ? Color.red : Color.green)
            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
        })
        // makes all taps go to the original button
        .allowsHitTesting(false)
        .padding(10)
        .background(alarmstate ? Color.red : Color.green)
        .background(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

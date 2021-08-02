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
    @ObservedObject var store: DeviceStore
    @StateObject var data = DeviceData()
    @State private var connected = false
    //@State var showSecuritySettingsView = false  // not used yet
    @State var showStatusDetailsView = false
    @State var showPasswordView = false
    @State var oneSecTimer: Timer? = nil
    @State var inAlarm = false
    @State var hideStatusDetails = true
    @State var showSetPassword = false
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
                    Text("\(store.deviceData.RPM)")
                        .fontWeight(.bold)
                        .font(.title2)
                }.padding()
                
                HStack{
                    Text("Motor Status: ").font(.subheadline)
                    Text(store.deviceData.getGOString())
                        .fontWeight(.bold)
                        .font(.title2)
                }.padding()
                
                VStack{
                    HStack{
                        Text("Motor Speed:").font(.subheadline)
                        Text("\(store.speed, specifier: "%g") %")
                            .fontWeight(.bold)
                            .font(.title2)
                        Image(systemName: !data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified) ? "lock" : "lock.open")
                    }
                    
                    HStack{
                        Image(systemName: "minus")
                        Slider(value: $store.speed, in: 0...100, step: 1 ){
                            editing in if !editing {
                                FlowIndexChanged()
                            }
                        }
                        .accentColor(Color.green)
                        .disabled(!data.PWEnableStatusReceived || (data.userPasswordEnabled && !data.userPasswordVerified))
                        Image(systemName: "plus")
                    }
                }.padding()
                
                Button(action: {
                        self.showPasswordView.toggle()
                }){
                    Text("Unlock")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background( Color.white )
                }
                // disable Unlock button if user and admin passwords are not used or already verified
                .disabled(!data.PWEnableStatusReceived || (!data.adminPasswordEnabled || data.adminPasswordVerified) && (!data.userPasswordEnabled || data.userPasswordVerified))
                .buttonStyle(RoundedRectangleButtonStyle())
                .sheet(isPresented: $showPasswordView, content: {
                    Password(showViewState: $showPasswordView, store: store, mode: PassWordViewMode.eVerify, data: data)
                        .animation(.spring())
                        .transition(.slide)
                })
                
                if !self.$hideStatusDetails.wrappedValue {
                    Button(action: {
                        // set flag to show status details view
                        self.showStatusDetailsView.toggle()
                    }){
                        Text("Status Details")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background( inAlarm ? Color.red : Color.white )
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                    .sheet(isPresented: $showStatusDetailsView, content: {
                        StatusDetails(data: self.data, store: self.store, showViewState: $showStatusDetailsView, RPMAlarmEnabled: data.RPMAlarmEnabled, filter1Enabled: data.filterMonitors[0].filterEnabled, filter2Enabled: data.filterMonitors[1].filterEnabled, filter3Enabled: data.filterMonitors[2].filterEnabled, filterMonitoringEnabled: data.filterMonitors[0].filterEnabled || data.filterMonitors[1].filterEnabled || data.filterMonitors[2].filterEnabled  )
                                    .animation(.spring())
                                    .transition(.slide)
                    })
                }
                    
                if self.uiDevice == .pad {

                    Button(action: {
                        //store.isAliveListener = nil
                        store.disconnect(targetPeripheral: targetDevice.peripheral)
                        //oneSecTimer?.invalidate()
                    }) {
                        Text("Disconnect")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background( Color.white )
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())

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
                .buttonStyle(RoundedRectangleButtonStyle())
            } label: {
                 Image(systemName: "ellipsis.circle")
            })
            .sheet(isPresented: $showSetPassword, content: {
                Password(showViewState: $showSetPassword, store: store, mode: PassWordViewMode.eEdit, data: data)
                    .animation(.spring())
                    .transition(.slide)
            })
        }
        .onAppear(){
            print("DeviceDetail appearing")
            store.isAliveListener = self
            data.PWEnableStatusReceived = false
            // we know the blutooth is already running since the user was able to scan bluetooth  // devices and select from the device list connect to device.
            //store.connect(targetPeripheral: targetDevice.peripheral) //moved to ContentView when the device is tapped in the device list
            store.setData(data)
            startOneSecTimer()
        }
        .onDisappear(){
            print("DeviceDetail disappearing")
            store.isAliveListener = nil
            if self.uiDevice == .phone {
                store.disconnect(targetPeripheral: targetDevice.peripheral)
            }
            oneSecTimer?.invalidate()
        }
    }
    
    func FlowIndexChanged(){
        store.sendFlowIndex()
    }
    
    func deviceNameChanged(_ newName: String){
        store.sendDeviceName(NewDeviceName: newName)
    }
    
    func startOneSecTimer()
    {
        oneSecTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
              // 2. Check time to add to H:M:S
              inAlarm = data.RPMInAlarm ||
                data.filterMonitors[0].FilterAlarmStatus() == FilterStatus.Bad ||
                data.filterMonitors[1].FilterAlarmStatus() == FilterStatus.Bad  ||
                data.filterMonitors[2].FilterAlarmStatus() == FilterStatus.Bad
            
            var version3AndHigher = false
            if let version = data.getMajorVision() {
                if version >= 3 { version3AndHigher = true }
            }
                
            hideStatusDetails = !(data.IsRPMOrFilterMonitoringEnabled() && version3AndHigher)
            
            if uiDevice == .phone {
                store.isBLEConectionStillAlive()
            }
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
    func makeBody(configuration: Configuration) -> some View {
        Button(action:{}, label: {
            HStack{
                Spacer()
                configuration.label.foregroundColor(.black)
                Spacer()
            }
        })
        // makes all taps go to the original button
        .allowsHitTesting(false)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

//
//  DeviceDetail.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI
import CoreBluetooth

struct DeviceDetail: View {
    let targetDevice: Device
    @State var deviceNameStr: String
    @ObservedObject var store: DeviceStore
    @StateObject var data = DeviceData()
    @State private var connected = false
    @State var showSecuritySettingsView = false
    @State var showStatusDetailsView = false

    var body: some View {
        
        VStack{
            List{
                HStack{
                    Text("Device Type:").font(.subheadline)
                    Text(targetDevice.getTypeString())
                        .fontWeight(.bold)
                        .font(.title2)
                }.padding()
                HStack{
                    Text("Device Name:").font(.subheadline)
                    Text(deviceNameStr)
                        .fontWeight(.bold)
                        .font(.title2)
//                    TextField("", text: $deviceNameStr, onCommit: {
//                        deviceNameChanged(deviceNameStr)
//                    })
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .font(Font.title2.weight(.heavy))
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
                    }
                    
                    HStack{
                        Image(systemName: "minus")
                        Slider(value: $store.speed, in: 0...100, step: 1 ){
                            editing in if !editing {
                                FlowIndexChanged()
                            }
                        }
                            .accentColor(Color.green)
//                            .onChange(of: store.speed){ _ in speedChanged() }
                        Image(systemName: "plus")
                    }
                }.padding()
                
//                Text("Status Details")
//                    .fontWeight(.bold)
//                    .font(.title2)
//
//                Text("Motor Settings")
//                    .fontWeight(.bold)
//                    .font(.title2)
//
//                Text("Security Settings")
//                    .fontWeight(.bold)
//                    .font(.title2)
                
                HStack{
                    Button(action: {
                        // set flag to show status details view
                        self.showStatusDetailsView.toggle()
                    }){
                        Text("Status Details")
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                    .sheet(isPresented: $showStatusDetailsView, content: {
                        StatusDetails(data: self.data, store: self.store, showViewState: $showStatusDetailsView)
                                .animation(.spring())
                                .transition(.slide)
                    })

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
            }
            .navigationBarTitle("Device Detail")
        }
        .onAppear(){
            print("DeviceDetail appearing")
            print("")
            // we know the blutooth is already running since the user was able to scan bluetooth devices
            // and select from the device list
            // connect to device.
            store.connect(targetPeripheral: targetDevice.peripheral)
            store.setData(data)
        }
        .onDisappear(){
            print("DeviceDetail disappearing")
            store.disconnect(targetPeripheral: targetDevice.peripheral)
        }
    }
    
    func FlowIndexChanged(){
        store.sendFlowIndex()
    }
    
    func deviceNameChanged(_ newName: String){
        store.sendDeviceName(NewDeviceName: newName)
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

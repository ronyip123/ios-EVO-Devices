//
//  FilteredDeviceDiscovery.swift
//  EVO Devices
//
//  Created by Ronald Yip on 10/8/24.
//

import SwiftUI

struct AddDeviceGroup: View {
    @Binding var showViewState: Bool
    @Binding var filteredDeviceNameArray: [String]
    var store : DeviceStore
    @State private var selectedDevices = Set<Device>()//Set<UUID>()
    //@State var inEditMode = false
    //@State var changeNotSaved = false
    @State var groupNameStr: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack{
                    Text("Group Name:").font(.subheadline)
                    TextField("", text: $groupNameStr, onCommit: {
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(Font.title2.weight(.heavy))
                }.padding()
                .navigationTitle("Add Device Group")
                
                List(store.devices, id: \.self) { device in
                    Button {
                        if selectedDevices.contains(device) {
                            selectedDevices.remove(device)
                        } else {
                            selectedDevices.insert(device)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(device.getNameString())
                                    .font(.headline)
                                    .foregroundColor(.black)

                                Text("RSSI: \(device.deviceRSSI) dBm")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            if selectedDevices.contains(device) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                
                
                HStack
                {
                    Button( action: {
                        // Do the following when the Save button is pressed
                        // - Create a new device group using the new group name and selectedDevices
                        // - Add the new device group into store.deviceGroups
                        // - call store.saveGroups() to persist the updated store.deviceGroups
                        // - set showViewState = false to exit
                        let newGroup = Device_Group(groupNameStr)
                        for d in selectedDevices
                        {
                            newGroup.addDeviceToGroup(d)
                        }
                        store.deviceGroups.insert(newGroup)
                        store.saveGroups()
                        showViewState = false
                    })
                    {
                        HStack{
                            Text("Save")
                                .padding()
                                .font(.title)
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                    .disabled( selectedDevices.isEmpty || groupNameStr.isEmpty)  // disable the Save button if the user has not selected any device for the new group.
                    
                    Button( action: {showViewState = false})
                    {
                        HStack{
                            Text("Cancel")
                                .padding()
                                .font(.title)
                            Image(systemName: "x.square")
                        }
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                }
            }
        }
    }
}

//#Preview {
//    FilteredDeviceDiscovery( filteredDeviceNameArray: <#Binding<[String]>#>, store: <#DeviceStore#>)
//}

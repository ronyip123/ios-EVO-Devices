//
//  EditDeviceGroup.swift
//  EVO Devices
//
//  Created by Ronald Yip on 10/15/26.
//
import SwiftUI

struct EditDeviceGroup: View {
    @Binding var showViewState: Bool
    var store : DeviceStore
    var group : Device_Group
    var sortMethod :DeviceStore.DeviceListSortMode
    var combined_store_devices_and_group_offline_devices : [Device]
    @State private var selectedDevices = Set<Device>()
    
    @State var groupNameStr: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack{
                    Text("Group Name:\(group.groupName)").font(.subheadline)
                }.padding()
                .navigationTitle("Edit Device Group")
                
                List(sortedDevices(combined_store_devices_and_group_offline_devices), id: \.self) { device in
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
                                    //.foregroundColor(.black)
                                if (device.deviceRSSI == Device_Group.NO_SIGNAL)
                                {
                                    Text("Offline")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                else
                                {
                                    Text("RSSI: \(device.deviceRSSI) dBm")
                                        .font(.subheadline)
                                    //.foregroundColor(.black)
                                }
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
                        // - Clear device list in group
                        // - Add selected devices in the existing group
                        // - call store.saveGroups() to persist the updated store.deviceGroups
                        // - set showViewState = false to exit
                        group.clearDeviceList()
                        for d in selectedDevices
                        {
                            group.addDeviceToGroup(d)
                        }
                        group.devices = sortedDevices(group.devices)
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
                    .disabled( selectedDevices.isEmpty)  // disable the Save button if the user has not selected any device for the new group.
                    
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
            .onAppear(){
                selectedDevices = Set(group.devices)
            }
        }
    }
    
    private func sortedDevices(_ devices: [Device]) -> [Device] {
        switch sortMethod {
        case .eNone:
            return devices

        case .eAlphabeticalOrder:
            return devices.sorted {
                $0.getNameString().localizedCaseInsensitiveCompare(
                    $1.getNameString()
                ) == .orderedAscending
            }

        case .eSignalStrength:
            return devices.sorted {
                $0.deviceRSSI > $1.deviceRSSI
            }
        }
    }
}

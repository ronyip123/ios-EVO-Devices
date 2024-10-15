//
//  FilteredDeviceDiscovery.swift
//  EVO Devices
//
//  Created by Ronald Yip on 10/8/24.
//

import SwiftUI

struct EditFilteredDeviceList: View {
    @Binding var showViewState: Bool
    @Binding var filteredDeviceNameArray: [String]
    var devices : [Device]
    @State private var deviceSelections = Set<Device>()//Set<UUID>()
    
    var body: some View {
        NavigationView {
            VStack {
                List(devices, id: \.self, selection: $deviceSelections) { device in
                    VStack{
                        Text(device.getNameString())
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("RSSI: \(device.deviceRSSI) dBm")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
                .navigationTitle("Edit Device Filter")
                .toolbar {
                    EditModeView(itemSelection: $deviceSelections, devices: devices, filteredDeviceNameArray: filteredDeviceNameArray)
                }
                HStack
                {
                    Button( action: {
                        filteredDeviceNameArray.removeAll()
                        for device in devices where deviceSelections.contains(device)
                        {
                            filteredDeviceNameArray.append(device.getNameString())
                        }
                        
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
                    .disabled(deviceSelections.isEmpty)
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

struct EditModeView: View {
    
    @Environment(\.editMode) var editMode
    @Binding var itemSelection: Set<Device>
    var devices : [Device]
    var filteredDeviceNameArray : [String]
    
    var body: some View {
        EditButton()
            .onChange(of: editMode?.wrappedValue.isEditing, perform: { newValue in
                
                for device in devices where filteredDeviceNameArray.contains(device.getNameString())
                {
                    itemSelection.insert(device)
                }
            })
    }
}

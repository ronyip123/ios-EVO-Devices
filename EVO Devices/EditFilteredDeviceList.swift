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
    @StateObject var store : DeviceStore
    
    @State private var multiSelection = Set<UUID>()
    
    var body: some View {
        NavigationView {
            VStack {
                List(store.devices, selection: $multiSelection) { device in
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
                    EditButton()
                }
                HStack
                {
                    Button( action: {
                        filteredDeviceNameArray.removeAll()
                        for device in store.devices
                        {
                            if (multiSelection.contains(device.id))
                            {
                                filteredDeviceNameArray.append(device.getNameString())
                            }
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
                    .disabled(multiSelection.isEmpty)
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



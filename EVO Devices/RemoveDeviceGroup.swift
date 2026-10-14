//
//  RemoveDeviceGroup.swift
//  EVO Devices
//
//  Created by Ronald Yip on 10/14/26.
//
import SwiftUI

struct RemoveDeviceGroup: View {
    @Binding var showViewState: Bool
    var store : DeviceStore

    @State private var selectedGroups = Set<Device_Group>()//Set<UUID>()
    //@State var inEditMode = false
    //@State var changeNotSaved = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(Array(store.deviceGroups), id: \.self) { group in
                    Button {
                        if selectedGroups.contains(group) {
                            selectedGroups.remove(group)
                        } else {
                            selectedGroups.insert(group)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(group.groupName)
                                    .font(.headline)
                            }

                            Spacer()

                            if selectedGroups.contains(group) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                HStack
                {
                    Button( action: {
                        // Remove the selected groups from store.deviceGroups
                        // Persist the updated deviceGroups
                        // set showViewState = false to exit
                        for g in selectedGroups
                        {
                            store.deviceGroups.remove(g)
                        }
                        store.saveGroups()
                        showViewState = false
                    })
                    {
                        HStack{
                            Text("Remove")
                                .padding()
                                .font(.title)
                            Image(systemName: "trash")
                        }
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                    .disabled( selectedGroups.isEmpty)  // disable the Remove button if the user has not selected any group.
                    
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
            .navigationTitle("Remove Device Group")
        }
    }
}

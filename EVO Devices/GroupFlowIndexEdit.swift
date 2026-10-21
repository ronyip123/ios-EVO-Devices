//
//  GroupFlowIndexEdit.swift
//  EVO Devices
//
//  Created by Ronald Yip on 10/19/26.
//
import SwiftUI

struct GroupFlowIndexEdit: View{
    @Binding var showViewState: Bool
    let store : DeviceStore
    let group : Device_Group
    @State var groupFlowIndex : Double
    @State var userPassword = ""
    //*** New Code for Group Flow Index
    @ObservedObject private var batchStore: DeviceStore

    init(showViewState: Binding<Bool>, store: DeviceStore, group: Device_Group, groupFlowIndex: Double) {
        self._showViewState = showViewState
        self.store = store
        self.group = group
        self._groupFlowIndex = State(initialValue: groupFlowIndex)
        self._batchStore = ObservedObject(wrappedValue: store)
    }
    //*** New Code for Group Flow Index ends
    
    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    // show group flow index
                    Text("Group Flow Index:")
                        .font(.system(size: 20, weight: .bold))
                        
                    Text("\(groupFlowIndex, specifier: "%g") %")
                        .font(.system(size: 20, weight: .regular))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Group Flow Index\nCommand")
                            .font(.system(size: 25, weight: .bold))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                
                HStack{
                    Button(action: {
                        print("decrement output by 1 %.")
                        if (groupFlowIndex > 0)
                        {
                            groupFlowIndex -= 1;
                            //FlowIndexChanged()
                        }
                    })
                    {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(BorderlessButtonStyle()) // to avoid tap button in HStack activating all button actions
                    //See https://www.hackingwithswift.com/forums/swiftui/tap-button-in-hstack-activates-all-button-actions-ios-14-swiftui-2/2952
                                                            
                    Slider(value: $groupFlowIndex, in: 0...100, step: 1 ){
                        
                    }
                                                            
                    Button(action: {
                        // launch sort options dialog
                        print("increment output by 1 %.")
                        if (groupFlowIndex < 100)
                        {
                            groupFlowIndex += 1;
                            //FlowIndexChanged()
                        }
                    })
                    {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(BorderlessButtonStyle()) // to avoid tap button in HStack activating all button actions
                }
                .accentColor(Color.green)
                .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                .padding()
                
                Text("User Password:")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                SecureField("Max 20 characters", text: $userPassword)
                     .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.black)
                    .padding()
                
                HStack{
                    Button( action:{
                        group.groupFlowIndex = UInt8(groupFlowIndex)
                        store.saveGroups()
                        
                        // Here is the process flow for the Group Flow Index Command
                        // Start processing all devices in the group
                        
                        //GroupFlowIndexEdit
                        //User enters Flow Index and password
                        //          V
                        //User presses Start
                        //Start BLE operation and dismiss sheet
                        //          V
                        //GroupDetails
                        //Displays progress and device counts
                        //          V
                        //DeviceStore
                        //Processes devices sequentially, skipping offline devices and authenticating when required
                        //          V
                        //GroupDetails
                        //Displays completion alert with results
                        
                        store.startGroupFlowIndex(
                            group: group,
                            flowIndex: UInt8(groupFlowIndex),
                            password: userPassword
                        )
                        
                        // Dismiss GroupFlowIndexEdit immediately
                        showViewState = false
                    })
                    {
                        HStack{
                            Text("Start")
                                .padding()
                                .font(.title)
                            Image(systemName: "play")
                        }
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
                    //*** New Code for Group Flow Index
                    .disabled(batchStore.groupFlowIndexCommandRunning)
                    //*** New Code for Group Flow Index ends
                    
                    Button( action:{
                        showViewState = false
                    })
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
                //*** New Code for Group Flow Index
                // Moved the progress and summary to GroupDetails
//                if batchStore.groupFlowIndexCommandRunning {
//                    ProgressView(value: Double(batchStore.groupFlowCompleted + batchStore.groupFlowFailed + batchStore.groupFlowSkipped), total: Double(max(batchStore.groupFlowTotal, 1)))
//                }
//                Text(batchStore.groupFlowStatus)
//                Text("Succeeded: \(batchStore.groupFlowCompleted)   Failed: \(batchStore.groupFlowFailed)   Offline: \(batchStore.groupFlowSkipped)")
//                    .font(.footnote)
                // New Code for Group Flow Index ends
            }
        }
    }
}

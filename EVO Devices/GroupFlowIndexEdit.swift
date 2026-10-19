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
            }
        }
    }
}

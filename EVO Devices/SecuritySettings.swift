//
//  SecuritySettings.swift
//  EVO Devices
//
//  Created by Ronald Yip on 6/12/21.
//

import SwiftUI

struct SecuritySettings: View {
    @ObservedObject var data: DeviceData
    @ObservedObject var store: DeviceStore
    @Binding var showViewState: Bool
    @State var userPasswordEnabled = false
    @State var adminPasswordEnabled = false
    @ObservedObject var userPassword = TextLimiter(limit: 20)
    @ObservedObject var adminPassword = TextLimiter(limit: 20)
    
//    init( userPassword user :String, adminPassword admin :String, userPasswordEnableState userState :Bool, adminPasswordEnableState adminState :Bool, showViewState: Bool){
//        self.userPasswordEnabled = userState
//        self.adminPasswordEnabled = adminState
//        self.userPassword.value = user
//        self.adminPassword.value = admin
//        self.showSecuritySettingsView = showViewState
//    }
    
    var body: some View {
        
        NavigationView{
            List{
                HStack{
                    Text("User Password: ").font(.subheadline)
                    if userPasswordEnabled {
                        Text("Enabled")
                            .font(Font.title2.weight(.heavy))
                    }
                    else{
                        Text("Disabled")
                            .font(Font.title2.weight(.heavy))
                    }
                    Button(action: { userPasswordEnabled.toggle() }){
                        if userPasswordEnabled {
                            Text("Disable")
                        }
                        else {
                            Text("Enable")
                        }
                        
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                }
                .padding()
                
                HStack{
                    TextField("up to 20 characters", text: $userPassword.value, onCommit: {
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(Font.title2.weight(.heavy))
                    .disabled(!userPasswordEnabled)
                    .foregroundColor(userPasswordEnabled ? .black : .gray)
                    .border(Color.red, width: $userPassword.hasReachedLimit.wrappedValue ? 1 : 0 )
                }
                
                HStack{
                    Text("Admin Password: ").font(.subheadline)
                    if adminPasswordEnabled {
                        Text("Enabled")
                            .font(Font.title2.weight(.heavy))
                    }
                    else{
                        Text("Disabled")
                            .font(Font.title2.weight(.heavy))
                    }
                    Button(action: { adminPasswordEnabled.toggle() }){
                        if adminPasswordEnabled {
                            Text("Disable")
                        }
                        else {
                            Text("Enable")
                        }
                        
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                }
                .padding()
                
                HStack{
                    TextField("up to 20 characters", text: $adminPassword.value, onCommit: {
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(Font.title2.weight(.heavy))
                    .disabled(!adminPasswordEnabled)
                    .foregroundColor(adminPasswordEnabled ? .black : .gray)
                    .border(Color.red, width: $adminPassword.hasReachedLimit.wrappedValue ? 1 : 0 )
                }
                Button( action:{showViewState.toggle()}){
                    Text("Done")
                        .padding()
                }
                .buttonStyle(RoundedRectangleButtonStyle())
                
            }
                .navigationBarTitle("Security Settings")
        }
        .onAppear(){
            print("Security Settings appearing")
            self.userPasswordEnabled = data.userPasswordEnabled
            self.adminPasswordEnabled = data.adminPasswordEnabled
            self.userPassword.value = data.userPassword
            self.adminPassword.value = data.adminPassword
        }
        .onDisappear(){
            print("Security Settings disappearing")
        }
    }
}

//struct SecuritySettings_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var value = false
//        SecuritySettings(data: DeviceData(), store: DeviceStore(), showViewState: $value)
//    }
//}

class TextLimiter: ObservableObject {
    private let limit: Int
    
    init(limit: Int){
        self.limit = limit
    }
    
    @Published var hasReachedLimit = false
    @Published var value = "" {
        didSet {
            if value.count > self.limit {
                value = String(value.prefix(self.limit))
                self.hasReachedLimit = true
            }
            else {
                self.hasReachedLimit = false
            }
        }
    }
    
}

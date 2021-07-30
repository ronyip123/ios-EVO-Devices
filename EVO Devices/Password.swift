//
//  Password.swift
//  EVO Devices
//
//  Created by Ronald Yip on 7/4/21.
//

import SwiftUI

enum PassWordViewMode
{
    case eEdit
    case eVerify
}

// This struct is for verify and edit passwords according to the mode provided by the
// calling view
struct Password: View {
    @State var userPassword = ""
    @State var adminPassword = ""
    @State var userPasswordEnabled = false
    @State var adminPasswordEnabled = false
    @Binding var showViewState: Bool
    @ObservedObject var store: DeviceStore
    @Environment(\.colorScheme) var colorScheme
    var mode : PassWordViewMode
    @ObservedObject var data: DeviceData
    
    var body: some View {
        NavigationView{
            List{
                Spacer()
//            Text("Unlock")
//                .font(.system(size: 64, weight: .semibold))
//                .foregroundColor(.white)
                VStack(alignment: .leading){
                    HStack{
                        Text("User Password:")
                        if mode == .eEdit {
                            Button( action: {
                                // if user password is currently enabled, disable it.
                                // if user password is currently disabled, enable it.
                                //store.enableUserPassword(enableState: data.userPasswordEnabled ? false : true)
                                userPasswordEnabled.toggle()
                                if userPasswordEnabled {
                                    adminPasswordEnabled = true
                                }
                            }){
                                userPasswordEnabled ? Text("Disable") : Text("Enable")
                            }
                            .buttonStyle(RoundedRectangleButtonStyle())
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        }
                        
                    }
                    HStack{
                        Image(systemName: userPasswordEnabled ?  "lock" : "lock.open")
                             .foregroundColor(.gray)
                        SecureField("Max 20 characters", text: $userPassword)
                             .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                    }
                    .frame(height: 60)
                    //.padding(.horizontal, 20)
                    .background(Color.white)
                    .cornerRadius(8)
                    if mode == .eEdit {
                        Text("Password: \(userPassword)")
                    }
                }
                .padding()
                
                VStack(alignment: .leading){
                    HStack{
                        Text("Admin Password:")
                        if mode == .eEdit {
                            Button( action: {
                                adminPasswordEnabled.toggle()
                                if !adminPasswordEnabled {
                                    userPasswordEnabled = false
                                }
                            }){
                                adminPasswordEnabled ? Text("Disable") : Text("Enable")
                            }
                            .buttonStyle(RoundedRectangleButtonStyle())
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        }
                    }
                    
                    HStack{
                        Image( systemName: adminPasswordEnabled ?  "lock" : "lock.open")
                             .foregroundColor(.gray)
                        SecureField("Max 20 characters", text: $adminPassword)
                             .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                    }
                    .frame(height: 60)
                    //.padding(.horizontal, 20)
                    .background(Color.white)
                    .cornerRadius(8)
                    if mode == .eEdit {
                        Text("Password: \(adminPassword)")
                    }
                }
                .padding()
                
                HStack{
                    Button( action:{
                        switch mode {
                        case .eVerify:
                            if adminPassword.count != 0 {
                                print(adminPassword)
                                store.verifyAdminPassword(AdminPassword: adminPassword)
                            }
                            else if userPassword.count != 0 {
                                print(userPassword)
                                store.verifyUserPassword(UserPassword: userPassword)
                            }
                        case .eEdit:
                            if data.userPasswordEnabled != userPasswordEnabled {
                                store.enableUserPassword(enableState: userPasswordEnabled)
                            }
                            
                            if data.adminPasswordEnabled != adminPasswordEnabled {
                                store.enableAdminPassword(enableState: adminPasswordEnabled)
                            }
                            
                            if adminPassword.count != 0 {
                                print(adminPassword)
                                store.setAdminPassword(AdminPassword: adminPassword)
                            }
                            
                            if userPassword.count != 0 {
                                print(userPassword)
                                store.setUserPassword(UserPassword: userPassword)
                            }
                        }

                        showViewState.toggle()
                        
                    }){
                        Text("Submit")
                            .padding()
                            .foregroundColor( colorScheme == .light ? .black : .white)
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                    
                    Button( action:{showViewState = false}){
                        Text("Cancel")
                            .padding()
                            .foregroundColor( colorScheme == .light ? .black : .white)
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                }
            
                Spacer()
            }
            .listStyle(SidebarListStyle())
            .navigationBarTitle(
                mode == .eVerify ? "Unlock" : "Set Password"
            )
        }
        .onAppear(){
            self.userPasswordEnabled = data.userPasswordEnabled
            self.adminPasswordEnabled = data.adminPasswordEnabled
            self.userPassword = data.userPassword
            self.adminPassword = data.adminPassword
        }
//        .background(
//            Image("Lock")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//        )
        //.edgesIgnoringSafeArea()
        
        
    }
}

//struct Password_Previews: PreviewProvider {
//    @State var viewState = true
//    static var previews: some View {
//        Group{
//            Password(showViewState: $viewState).previewDevice("iPhone 8")
//            Password(showViewState: $viewState).previewDevice("iPhone 12 Pro Max")
//            Password(showViewState: $viewState).previewDevice("iPhone 12 mini")
//        }
//    }
//}

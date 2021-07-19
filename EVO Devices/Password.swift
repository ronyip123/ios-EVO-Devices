//
//  Password.swift
//  EVO Devices
//
//  Created by Ronald Yip on 7/4/21.
//

import SwiftUI

struct Password: View {
    @State var userPassword = ""
    @State var adminPassword = ""
    @Binding var showViewState: Bool
    @ObservedObject var store: DeviceStore
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView{
            List{
                Spacer()
//            Text("Unlock")
//                .font(.system(size: 64, weight: .semibold))
//                .foregroundColor(.white)
                VStack{
                    Text("User Password:")
                    HStack{
                        Image(systemName: "lock")
                             .foregroundColor(.gray)
                        SecureField("Password", text: $userPassword)
                             .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                    }
                    .frame(height: 60)
                    //.padding(.horizontal, 20)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding()
                
                VStack{
                    Text("Admin Password:")
                    HStack{
                        Image(systemName: "lock")
                             .foregroundColor(.gray)
                        SecureField("Password", text: $adminPassword)
                             .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                    }
                    .frame(height: 60)
                    //.padding(.horizontal, 20)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding()
                
                
                HStack{
                    Button( action:{
                        if adminPassword.count != 0 {
                            print(adminPassword)
                            store.verifyAdminPassword(AdminPassword: adminPassword)
                        }
                        else if userPassword.count != 0 {
                            print(userPassword)
                            store.verifyUserPassword(UserPassword: userPassword)
                        }
                        showViewState.toggle()
                        
                    }){
                        Text("Submit")
                            .padding()
                            .foregroundColor( colorScheme == .light ? .black : .white)
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                    
                    Button( action:{showViewState.toggle()}){
                        Text("Cancel")
                            .padding()
                            .foregroundColor( colorScheme == .light ? .black : .white)
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                }
            
                Spacer()
            }
            .listStyle(SidebarListStyle())
            .navigationBarTitle("Unlock")
        }
        .onAppear(){
            
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

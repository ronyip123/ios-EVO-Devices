//
//  About.swift
//  EVO Devices
//
//  Created by Ronald Yip on 7/27/21.
//

import SwiftUI

struct About: View {
    @Binding var showViewState: Bool
    @State var viewTimer: Timer? = nil
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
    
    
    var body: some View {
        VStack{
            HStack {
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                Text("Evolution Controls Inc.")
                    .font(.title)
            }
            Text("EVO Devices")
                .padding()
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            if let version = appVersion {
                Text("Version: \(version)")
                    .font(.title)
            }
            if let bundle = appBuild {
                Text("Build: \(bundle)")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }
        }
        .onAppear(){
            StartViewTimer()
        }
        .onDisappear(){
            viewTimer?.invalidate()
        }
    }
    
    
    func StartViewTimer()
    {
        viewTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false){ _ in
            showViewState = false
        }
    }
}

//struct About_Previews: PreviewProvider {
//    @State var showAboutView = false
//    static var previews: some View {
//        About(showViewState: $showAboutView)
//    }
//}

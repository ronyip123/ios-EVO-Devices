//
//  EVO_DevicesApp.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI

@main
struct EVO_DevicesApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    var cv = ContentView()
    
//    init(){
//        // configure library
//        doSomething()
//    }
    
    var body: some Scene {
        
        WindowGroup {
//            ContentView()
            cv
        }
        .onChange(of: scenePhase){ phase in
            switch phase {
            case .active:
                print("active")
                cv.getReady()
                break
            case .inactive:
                print("inactive")
                cv.cleanup()
                break
            case .background:
                print("background")
                break
            @unknown default:
                print("something new added by apple")
            }
        }
    }
    
//    func doSomething(){
//
//    }
}

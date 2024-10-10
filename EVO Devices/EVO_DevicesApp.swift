//
//  EVO_DevicesApp.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI
import BackgroundTasks

@main
struct EVO_DevicesApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    var cv = ContentView()
    
    init(){
        // configure library
        //doSomething()
        //1. register a handler for the background task
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundAlarmTaskId, using: nil){ task in
//            //2. handle the task when it is run by the system
//            guard let task = task as? BGAppRefreshTask else {return}
//            self.alarmScanTask(task: task)
//        }
    }
    
//    private func alarmScanTask(task: BGAppRefreshTask)
//    {
//        let request = BGAppRefreshTaskRequest(identifier: backgroundAlarmTaskId) // Mark 1
//        request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: scanInterval, to: Date()) // Mark 2
//      
//        print("Scan alarm ")
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
                //cv.cleanup()
                break
            case .background:
                print("background")
                break
            @unknown default:
                print("something new added by apple")
            }
        }
    }
}

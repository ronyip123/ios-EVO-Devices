//
//  BackgroundAlarmTaskSettings.swift
//  EVO Devices
//
//  Created by Ronald Yip on 6/10/24.
//

import SwiftUI
import BackgroundTasks

let backgroundAlarmTaskId = "com.gotoevo.EVODevices.backgroundAlarmTask"
let scanInterval = 30 // seconds

struct BackgroundAlarmTaskSettings: View {
    
    @State private var backgroundTaskEnabled = false

    var body: some View {
        VStack{
            Button(action:{
                if (backgroundTaskEnabled)
                {
                    // disable background task
                    
                }
                else
                {
                    // request notification authorization
//                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
//                        if success {
//                            print("Notification is all set!")
//                        } else if let error = error {
//                            print(error.localizedDescription)
//                        }
//                    }
                                
                    // enable background task
                    let request = BGAppRefreshTaskRequest(identifier: backgroundAlarmTaskId) // Mark 1
                    request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: scanInterval, to: Date()) // Mark 2
                    do {
                        try BGTaskScheduler.shared.submit(request) // Mark 3
                        print("Background Task Scheduled!")
                    }
                    catch(let error)
                    {
                        print("Scheduling Error \(error.localizedDescription)")
                    }
                }
            })
            {
                if (backgroundTaskEnabled)
                {
                    Text("disable background task")
                }
                else
                {
                    Text("enable background task")
                }
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .padding()
        }
        .onAppear(){
            //check if background task is running
            BGTaskScheduler.shared.getPendingTaskRequests{ requests in
                print("\(requests.count) BGTasks pending...")
                
                guard requests.isEmpty else
                {
                    backgroundTaskEnabled = true
                    return
                } //enabled
                
                backgroundTaskEnabled = false
            }
        }
    }
}

#Preview {
    BackgroundAlarmTaskSettings()
}

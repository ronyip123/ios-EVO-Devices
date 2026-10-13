//
//  GroupDetails.swift
//  EVO Devices
//
//  Created by Ronald Yip on 10/7/26.
//


import SwiftUI

struct GroupDetails: View {
    
    let group: Device_Group
    @ObservedObject var store: DeviceStore
    @State var sortMethod: DeviceStore.DeviceListSortMode?
    
    @State private var groupName: String
    @State private var offLineDeviceCount : Int
    @State private var alarmDeviceCount: Int
    
//    @State private var hasStartedInitialScan = false
    
    @State var scanningGroup = false
    @State private var scanGroupTimer = 0
    private let scanGroupTimerPublisher =
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let scanGroupProgressView = ProgressView("Tap Stop Scan to stop..");
    
    // DeviceStore is actually not used in this View. It is passed in so that we can use
    // DeviceCell to display the Group devices in the list
    init(group: Device_Group, store: DeviceStore, sort: DeviceStore.DeviceListSortMode?) {
        self.group = group
        self.store = store
        self.sortMethod = sort
        _groupName = State(initialValue: group.groupName)
        alarmDeviceCount = group.devices.filter { device in
                    device.inFilterAlarm || device.inRPMAlarm
                }.count
        offLineDeviceCount = group.devices.filter { device in
                    device.deviceRSSI == Device_Group.NO_SIGNAL
                }.count
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Editable group name
            HStack {
                Text("Group Name:")
                    .fontWeight(.bold)
                
                TextField("Group Name", text: $groupName)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack{
                Text( String(group.devices.count) + " Controls").padding()
                Text(String(alarmDeviceCount) + " In Alarm").padding()
                Text(String(offLineDeviceCount) + " Offline").padding()
            }
            
            HStack{
                Button(action: {
                    
                }){
                    Text("Edit")
                        .fontWeight(.bold)
                        .font(.title)
                }
                .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(5.0)
                
                Button( action:{
                    self.scanningGroup.toggle()
                    if self.scanningGroup {
                        //store.clearStore()
                        //self.scanTimer = 0
                        cleanup()
                        startScan()
                    }
                    else{
                        stopScan()
//                        if let s = sortMethod {
//                            sort(sortMethod: s)
//                        }
                    }
                })
                {
                    if self.scanningGroup {
                        Text("Stop Scan")
                            .fontWeight(.bold)
                            .font(.title)
                    }
                    else {
                        Text("Start Scan")
                            .fontWeight(.bold)
                            .font(.title)
                    }
                }
                .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(5.0)
            }
            
            ZStack{
                // Device list
                List {
                    
                    ForEach(group.devices){device in
                            DeviceCell(device: device, store: store, scanning: $scanningGroup)
                                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                    .background(device.inRPMAlarm || device.inFilterAlarm ? Color.red : Color.white)
                        }
                    }
                .refreshable{
                    await MainActor.run {
                        cleanup()
                        self.scanningGroup = true
                        startScan()
                    }
                }
                
                //show progressView only if scanning
                if self.scanningGroup {
                    scanGroupProgressView
//                        .accentColor(Color.green)
                        .progressViewStyle(.circular)
                        .tint(.green )
                        .foregroundColor(.green)
                        .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                }
            }
        }
        .navigationTitle("Device Group")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(scanGroupTimerPublisher) { _ in
            if scanningGroup {
                scanGroupTimer += 1
                print(".onReceive: \(scanGroupTimer)")

                if scanGroupTimer >= ContentView.scanTime {
                    scanningGroup = false
                    stopScan()
                    print(".onReceive: scanGroupTimer = \(scanGroupTimer)")
                    
//                    if let s = sortMethod {
//                        sort(sortMethod: s)
//                    }
                }
            }
        }
        .onAppear(){
            print(">>> GroupDetails.onAppear")
            
            for device in group.devices {
                    print("GroupDetails. onAppear: Device: \(device.getNameString()), ID: \(device.id)")
                }
        }
        .onDisappear()
        {
            print(">>> GroupDetails.onDisappear")
        }
    }
    
//    func sort(sortMethod: DeviceStore.DeviceListSortMode)
//    {
//        switch (sortMethod)
//        {
//            case .eNone:
//                // do nothing
//                break;
//            case .eAlphabeticalOrder:
//                print("sort by alphabetucal order")
//            group.devices = group.devices.sorted{ $0.getNameString() < $1.getNameString() }
//            case .eSignalStrength:
//                print("sort by signal strength")
//            group.devices = group.devices.sorted{$0.deviceRSSI > $1.deviceRSSI }
//        }
//    }
    
    func startScan()
    {
        self.scanGroupTimer = 0
        store.startScan()
    }

    func stopScan()
    {
        store.stopScan()
    }
    
    func cleanup()
    {
        print("in cleanup")
        store.clearStore();
    }
}

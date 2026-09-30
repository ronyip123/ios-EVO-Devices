//
//  ContentView.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI
import CoreBluetooth
import BackgroundTasks

struct ContentView: View {
    
    let sortKey = "MySortListMethod"
    static let filteredDeviceNamesArrayKey = "FilteredDeviceNamesArrayKey"
    let scanTime = 10 //seconds
    @StateObject var store = DeviceStore()
    @State var scanning = false
    @State private var scanTimer = 0
    private let scanTimerPublisher =
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let scanProgressView = ProgressView("Tap Stop Scan to stop..");
    @State var showAbout = false
    @State var showBackgroundAlarmSettings = false
    @State var firstTime = true
    @State private var showingSortOptions = false
    @State var sortMethod: DeviceStore.DeiceListSortMode?
    //@State private var showingFilterOptions = false
    @State var filteredDeviceNamesArray = UserDefaults.standard.object(forKey: filteredDeviceNamesArrayKey) as? [String] ?? [String]()
    @State var showFilterDeviceEdit = false
    @State var showNoDeviceInFilterNameArrayMsg = false
    
    var body: some View {
        NavigationView{
            VStack{
                HStack
                {
                    Menu {
                        Button(action: {
                            selectSortMethod(.eAlphabeticalOrder)
                        }) {
                            Label(
                                "Alphabetical Order",
                                systemImage: sortMethod == .eAlphabeticalOrder
                                    ? "checkmark"
                                    : ""
                            )
                        }

                        Button(action: {
                            selectSortMethod(.eSignalStrength)
                        }) {
                            Label(
                                "Signal Strength",
                                systemImage: sortMethod == .eSignalStrength
                                    ? "checkmark"
                                    : ""
                            )
                        }

                        Button(action: {
                            selectSortMethod(.eNone)
                        }) {
                            Label(
                                "None",
                                systemImage: sortMethod == .eNone
                                    ? "checkmark"
                                    : ""
                            )
                        }
                        
                        Button( action: {
                            
                        }) {
                            Label(
                                "Cancel",
                                systemImage: "xmark"
                            )
                        }
                    } label: {
                        Image(systemName: "text.justify.left")
                    }
                        
                    Button( action:{
                        self.scanning.toggle()
                            if self.scanning {
                                //store.clearStore()
                                //self.scanTimer = 0
                                cleanup()
                                startScan()
                            }
                            else{
                                stopScan()
                                if let s = sortMethod {
                                    store.sort(sortMethod: s)
                                }
                            }
                    })
                    {
                        if self.scanning {
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
                    
                    Menu {
                        Button("Add Device Group"){
                            if (!store.devices.isEmpty)
                            {
                                showFilterDeviceEdit = true
                            }
                            else
                            {
                                showNoDeviceInFilterNameArrayMsg = true
                            }
                        }
                        Button("Remove Device Group") {
                            filteredDeviceNamesArray.removeAll()
                            UserDefaults.standard.set(filteredDeviceNamesArray, forKey: ContentView.filteredDeviceNamesArrayKey)
                        }

                        Button(action: {
                            selectSortMethod(.eNone)
                        }) {
                            Label(
                                "Cancel",
                                systemImage: "xmark"
                            )
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                .navigationBarTitle("EVO Devices")
                .navigationBarItems(trailing: Menu
                {
                    VStack{
                        Button( action: {self.showBackgroundAlarmSettings.toggle()})
                        {
                            HStack{
                                Text("Background Alarm Scanning")
                                Image(systemName: "gear")
                            }
                        }
                        Button ( action: { self.showAbout.toggle() } )
                        {
                            HStack{
                                Text("About")
                                Image(systemName: "info.circle")
                            }
                        }
                    }
                }
                label: {
                    Image(systemName: "ellipsis")
                })
                
                
                ZStack{
                    List{
                        
                    ForEach(store.devices){device in
                        if (filteredDeviceNamesArray.isEmpty || filteredDeviceNamesArray.contains(device.getNameString()))
                            {
                            DeviceCell(device: device, store: store, scanning: $scanning)
                                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                    .background(device.inRPMAlarm || device.inFilterAlarm ? Color.red : Color.white)
                            }
                        }
                    }
                    .refreshable{
                        await MainActor.run {
                                cleanup()
                                self.scanning = true
                                startScan()
                            }
                    }

                    //show progressView only if scanning
                    if self.scanning {
                        scanProgressView
                            .accentColor(Color.green)
                            .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                    }
                }
            }
            .onReceive(scanTimerPublisher) { _ in
                if scanning {
                    scanTimer += 1
                    print(".onReceive: \(scanTimer)")

                    if scanTimer >= scanTime {
                        scanning = false
                        stopScan()
                        print(".onReceive: scanTimer = \(scanTimer)")
                        
                        if let s = sortMethod {
                            store.sort(sortMethod: s)
                        }
                    }
                }
            }
            .onAppear(){
                print("ContentView appears")
                if firstTime {
                    // skip scanning if launched the first time after installation
                    firstTime = false
                }
                else {
                    cleanup()
                    self.scanning = true
                    self.scanTimer = 0
                    startScan()
                }
                
                if ( UserDefaults.standard.object(forKey: sortKey) == nil)
                {
                    UserDefaults.standard.setValue(DeviceStore.DeiceListSortMode.eNone.rawValue, forKey: sortKey)
                }
                else
                {
                    // userDefault has a value
                    self.sortMethod = DeviceStore.DeiceListSortMode(rawValue: UserDefaults.standard.integer(forKey: sortKey))
                }
                
                store.loadGroups()
//                store.test_persisting_Groups()
            }
            .onDisappear(){
                print("ContentView disappears")
                if scanning {
                    scanning = false
                    stopScan()
                }
            }
            .sheet(isPresented: $showAbout, content: {
                About(showViewState: $showAbout)
                  //  .animation(.spring())
                    .transition(.slide)
            })
            .sheet(isPresented: $showBackgroundAlarmSettings, content: {
               BackgroundAlarmTaskSettings()
                    .transition(.slide)
            })
            .sheet(isPresented: $showFilterDeviceEdit, content: {
                EditFilteredDeviceList(showViewState: $showFilterDeviceEdit, filteredDeviceNameArray: $filteredDeviceNamesArray, devices: store.devices)
                  //  .animation(.spring())
                    .transition(.slide)
            })
            .alert("No scanned device ", isPresented: $showNoDeviceInFilterNameArrayMsg) {
                Button("OK") { }
            }
        }
    }
    
    private func selectSortMethod(_ method: DeviceStore.DeiceListSortMode)
    {
        sortMethod = method
        UserDefaults.standard.setValue(method.rawValue, forKey: sortKey)
        store.sort(sortMethod: method)
    }
   
    func startScan()
    {
        self.scanTimer = 0
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
    
    func getReady() {
    }
}


//struct DeviceCell: View {
//    let device : Device
//    let store : DeviceStore
//    var body: some View {
//        NavigationLink(destination: DeviceDetail(targetDevice: device, deviceNameStr: device.getNameString(), store: store )){
//            VStack(alignment: .leading){
//                Text(device.getNameString())
//                    .font(.headline)
//                    .foregroundColor(.black)
//                Text("RSSI: \(device.deviceRSSI) dBm")
//                    .font(.subheadline)
//                    .foregroundColor(.black)
//            }
//
//        }
//    }
//}

struct DeviceCell: View {
    let device : Device
    let store : DeviceStore
    @Binding var scanning : Bool
    var body: some View {
        VStack {
            NavigationLink(destination: DeviceDetail(targetDevice: device, deviceNameStr: device.getNameString(), store: store )){
            }
            
            Button( action: {
                
                if scanning {
                    scanning = false
                    store.stopScan()
                }
                
                print("\(device.deviceName!) is tapped")
                store.connect(targetPeripheral: device.peripheral!)
            }){
                VStack(alignment: .leading){
                    let flow_index = device.getFlowIndexInAdvertisement()
                    
                    let alarmStr: String = {
                        if device.inRPMAlarm && device.inFilterAlarm {
                            return "RPM and Filter Alarm"
                        } else if device.inRPMAlarm {
                            return "RPM Alarm"
                        } else if device.inFilterAlarm {
                            return "Filter Alarm"
                        } else {
                            return ""
                        }
                    }()
                    
                    HStack(){
                        Text(device.getNameString())
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(Device.NO_FLOW_INDEX_IN_ADVERTISEMENT == flow_index ? "" : "F=" + String(flow_index) + "%")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    HStack(){
                        Text("RSSI: \(device.deviceRSSI) dBm")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Text("  ") // 2 character space
                        
                        Text(alarmStr)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                    }
                }
            }
        }
    }
}

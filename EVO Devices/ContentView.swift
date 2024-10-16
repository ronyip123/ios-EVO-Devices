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
    let scanTime = 30 //seconds
    @StateObject var store = DeviceStore()
    @State private var scanning = false
    @State private var scanTimer = 0
    let scanProgressView = ProgressView("Tap Stop Scan to stop..");
    @State var oneSecTimer: Timer? = nil
    @State var showAbout = false
    @State var showBackgroundAlarmSettings = false
    @State var firstTime = true
    @State private var showingSortOptions = false
    @State var sortMethod: DeviceStore.DeiceListSortMode?
    @State private var showingFilterOptions = false
    @State var filteredDeviceNamesArray = UserDefaults.standard.object(forKey: filteredDeviceNamesArrayKey) as? [String] ?? [String]()
    @State var showFilterDeviceEdit = false
    @State var showNoDeviceInFilterNameArrayMsg = false
    
    var body: some View {
        NavigationView{
            VStack{
                HStack
                {
                    Button(action: {
                        // launch sort options dialog
                        print("sort")
                        self.showingSortOptions = true
                    })
                    {
                        //Image(systemName: "line.3.horizontal.decrease")
                        Image(systemName: "text.justify.left")
                    }
                    .alert("Sort Device List By:", isPresented: $showingSortOptions) {
                        Button("Alphabetical Order", role: .none, action: {
                            self.sortMethod = DeviceStore.DeiceListSortMode.eAlphabeticalOrder
                            if let s = self.sortMethod {
                                UserDefaults.standard.setValue(s.rawValue, forKey: sortKey)
                                store.sort(sortMethod: s)
                            }
                        })
                        Button("Signal Strength", role: .none, action: {
                            self.sortMethod = DeviceStore.DeiceListSortMode.eSignalStrength
                            if let s = self.sortMethod {
                                UserDefaults.standard.setValue(s.rawValue, forKey: sortKey)
                                store.sort(sortMethod: s)
                            }
                        })
                        Button("None", role: .none, action: {
                            self.sortMethod = DeviceStore.DeiceListSortMode.eNone
                            if let s = self.sortMethod {
                                UserDefaults.standard.setValue(s.rawValue, forKey: sortKey)
                                store.sort(sortMethod: s)
                            }
                        })
                    }
                        
                    Button( action:{
                        self.scanning.toggle()
                            if self.scanning {
                                //store.clearStore()
                                self.scanTimer = 0
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
                    
                    Button(action: {
                        // launch filter options dialog
                        print("device filter")
                        self.showingFilterOptions = true
                    })
                    {
                        //Image(systemName: "line.3.horizontal.decrease")
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    .alert("Device Filter:", isPresented: $showingFilterOptions) {
                        Button("Edit Device Filter", role: .none, action: {
                            if (!store.devices.isEmpty)
                            {
                                showFilterDeviceEdit = true
                            }
                            else
                            {
                                showNoDeviceInFilterNameArrayMsg = true
                            }
                        })
                        Button("Remove Device Filter", role: .none, action: {
                            filteredDeviceNamesArray.removeAll()
                            UserDefaults.standard.set(filteredDeviceNamesArray, forKey: ContentView.filteredDeviceNamesArrayKey)
                        })
                        Button("Cancel", role: .none, action: {})
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
                                DeviceCell(device: device, store: store)
                                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                    .background(device.inAlarm ? Color.red : Color.white)
                            }
                        }
                    }

                    //show progressView only if scanning
                    if self.scanning {
                        ProgressView("tap Stop Scan to stop")
                            .accentColor(Color.green)
                            .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
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
            }
            .onDisappear(){
                print("ContentView disappears")
                if scanning {
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
    
    
    func startOneSecTimer()
    {
        oneSecTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            if self.scanTimer < scanTime {
                self.scanTimer += 1
                print(".onReceive: \(self.scanTimer)")
            }
            else
            {
                self.scanning.toggle()
                self.oneSecTimer?.invalidate()
                print(".onReceive: scanTimer = 30")
            }
        }
    }

   
    func startScan()
    {
        startOneSecTimer()
        store.startScan()
    }

    func stopScan()
    {
        self.oneSecTimer?.invalidate()
        store.stopScan()
    }
    
    func cleanup()
    {
        print("in cleanup")
        store.clearStore();
        self.oneSecTimer?.invalidate()
    }
    
    func getReady() {
//        self.scanTimer = scanTime
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
    var body: some View {
        VStack {
            NavigationLink(destination: DeviceDetail(targetDevice: device, deviceNameStr: device.getNameString(), store: store )){
            }
            
            Button( action: {
                print("\(device.deviceName!) is tapped")
                store.connect(targetPeripheral: device.peripheral)
            }){
                VStack(alignment: .leading){
                    Text(device.getNameString())
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("RSSI: \(device.deviceRSSI) dBm")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
        }
    }
}

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
    static let savedSelectedGroupIDKey = "SavedSelectedGroupIDKey"
    public static let scanTime = 10 //seconds
    @StateObject var store = DeviceStore()
    @State var scanningAll = false
    @State private var scanAllTimer = 0
    private let scanAllTimerPublisher =
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let scanAllProgressView = ProgressView("Tap Stop Scan to stop..");
    @State var showAbout = false
    @State var showBackgroundAlarmSettings = false
    @State var firstTime = true
    @State private var showingSortOptions = false
    @State var sortMethod: DeviceStore.DeviceListSortMode?
    @State var showAddDeviceGroup = false
    @State var showRemoveDeviceGroup = false
    @State var showNoScannedDeviceMsg = false
    @State var showNoDeviceGroupMsg = false
    @State private var selectedGroupID: UUID? =
        UserDefaults.standard.string(forKey: savedSelectedGroupIDKey)
            .flatMap { UUID(uuidString: $0) }
    @State private var selectedGroup: Device_Group?
    @State private var showGroupDetail = false
    
    var body: some View {
        NavigationView{
            VStack{
                VStack {
                    HStack
                    {
                        Button( action:{
                            self.scanningAll.toggle()
                            if self.scanningAll {
                                //store.clearStore()
                                //self.scanTimer = 0
                                for group in store.deviceGroups {
                                    group.reset_All_Devices_Before_Scanning()
                                }
                                cleanup()
                                startScan()
                            }
                            else{
                                stopScan()
                                if let s = sortMethod {
                                    store.sortDevices(sortMethod: s)
                                }
                                
                                openSelectedGroupDetails()
                            }
                        })
                        {
                            if self.scanningAll {
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
                        
                        VStack(spacing: 20){
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
                                HStack{
                                    Text("Sort")
                                    Image(systemName: "arrow.up.arrow.down")
                                }
                            }
                            //.padding()
                            
                            Menu {
                                Button("Add Device Group"){
                                    if (!store.devices.isEmpty)
                                    {
                                        showAddDeviceGroup = true
                                    }
                                    else
                                    {
                                        showNoScannedDeviceMsg = true
                                    }
                                }
                                Button("Remove Device Group") {
                                    if (!store.deviceGroups.isEmpty)
                                    {
                                        showRemoveDeviceGroup = true
                                    }
                                    else
                                    {
                                        showNoDeviceGroupMsg = true
                                    }
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
                                HStack{
                                    Text("Group")
                                    Image(systemName: "square.stack.3d.up")
                                }
                            }
                        }
                    }
                    .padding()
                    
                    HStack {
                        Text("Device Group:")

                        Picker("", selection: $selectedGroupID) {
                            Text("Select a group")
                                .tag(nil as UUID?)
                            ForEach(
                                Array(store.deviceGroups)
                                    .sorted { $0.groupName < $1.groupName }
                            ) { group in
                                Text(group.groupName)
                                    .tag(group.groupID as UUID?)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .font(.body)
                        .onChange(of: selectedGroupID) { newGroupID in
                            
                            print(">>> selectedGroupID = \(String(describing: newGroupID))")
                            selectedGroupID = newGroupID
                            if let groupID = newGroupID {
                                print("Selected group: \(groupID)")
                                UserDefaults.standard.set(
                                    groupID.uuidString,
                                    forKey: ContentView.savedSelectedGroupIDKey
                                )
                                
                                // Open immediately only if not scanning
                                if !scanningAll {
                                    openSelectedGroupDetails()
                                }
                            } else {
                                UserDefaults.standard.removeObject(
                                    forKey: ContentView.savedSelectedGroupIDKey
                                )
                                print("No group selected")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    //.frame(height: 50)
                    .padding(.horizontal)
                    
                    GroupNavigationLink(
                        group: selectedGroup,
                        store: store,
                        sortMethod: sortMethod,
                        isActive: $showGroupDetail
                    )
                    .onChange(of: showGroupDetail) { isActive in
                        print(">>> ContentView.showGroupDetail = \(isActive)")

                        if !isActive {
                            selectedGroupID = nil
                            selectedGroup = nil

                            UserDefaults.standard.removeObject(
                                forKey: ContentView.savedSelectedGroupIDKey
                            )
                        }
                    }
                }
                .navigationBarTitle("EVO Devices")
                .navigationBarItems(trailing: Menu
                {
                    VStack{
//                        Button( action: {self.showBackgroundAlarmSettings.toggle()})
//                        {
//                            HStack{
//                                Text("Background Alarm Scanning")
//                                Image(systemName: "gear")
//                            }
//                        }
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
                            DeviceCell(device: device, store: store, scanning: $scanningAll)
                                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                    .background(device.inRPMAlarm || device.inFilterAlarm ? Color.red : Color.white)
                        }
                    }
                    .refreshable{
                        await MainActor.run {
                                cleanup()
                                self.scanningAll = true
                                for group in store.deviceGroups {
                                    group.reset_All_Devices_Before_Scanning()
                                }
                                startScan()
                            }
                    }

                    //show progressView only if scanning
                    if self.scanningAll {
                        scanAllProgressView
                            //.accentColor(Color.green)
                            .progressViewStyle(.circular)
                            .tint(.green)
                            .foregroundColor(.green)
                            .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                    }
                }
            }
            .onReceive(scanAllTimerPublisher) { _ in
                if scanningAll {
                    scanAllTimer += 1
                    print(".onReceive: \(scanAllTimer)")

                    if scanAllTimer >= ContentView.scanTime {
                        scanningAll = false
                        stopScan()
                        print(".onReceive: scanAllTimer = \(scanAllTimer)")
                        
                        if let s = sortMethod {
                            store.sortDevices(sortMethod: s)
                        }
                        
                        openSelectedGroupDetails()
                    }
                }
            }
            .onAppear(){
                print(">>> ContentView.onAppear")
                print("showGroupDetail = \(showGroupDetail)")
                print("selectedGroupID = \(String(describing: selectedGroupID))")
                if firstTime {
                    // skip scanning if launched the first time after installation
                    firstTime = false
                    
                    store.loadGroups()
                    
                    if ( UserDefaults.standard.object(forKey: sortKey) == nil)
                    {
                        UserDefaults.standard.setValue(DeviceStore.DeviceListSortMode.eAlphabeticalOrder.rawValue, forKey: sortKey)
                        self.sortMethod = DeviceStore.DeviceListSortMode.eAlphabeticalOrder
                    }
                    else
                    {
                        // userDefault has a value
                        self.sortMethod = DeviceStore.DeviceListSortMode(rawValue: UserDefaults.standard.integer(forKey: sortKey)) ?? .eAlphabeticalOrder
                    }
                }
                else {
                    cleanup()
                    self.scanningAll = true
                    self.scanAllTimer = 0
                    startScan()
                }
//                store.test_persisting_Groups()
            }
            .onDisappear(){
                print("ContentView disappears")
                if scanningAll {
                    scanningAll = false
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
            .sheet(isPresented: $showAddDeviceGroup, content: {
                AddDeviceGroup(showViewState: $showAddDeviceGroup, store: store, sortMethod: sortMethod ?? DeviceStore.DeviceListSortMode.eAlphabeticalOrder)
                  //  .animation(.spring())
                    .transition(.slide)
            })
            .sheet(isPresented: $showRemoveDeviceGroup, content: {
                RemoveDeviceGroup(showViewState: $showRemoveDeviceGroup, store: store)
                  //  .animation(.spring())
                    .transition(.slide)
            })
            .alert("No scanned device ", isPresented: $showNoScannedDeviceMsg) {
                Button("OK") { }
            }
            .alert("No Device Group", isPresented: $showNoDeviceGroupMsg) {
                Button("OK") { }
            }
        }
    }
    
    private func openSelectedGroupDetails() {
        guard let groupID = selectedGroupID,
              let group = store.deviceGroups.first(where: {
                  $0.groupID == groupID
              }) else {
            return
        }

        selectedGroup = group
        showGroupDetail = true
    }
    
    private func selectSortMethod(_ method: DeviceStore.DeviceListSortMode)
    {
        sortMethod = method
        UserDefaults.standard.setValue(method.rawValue, forKey: sortKey)
        store.sortDevices(sortMethod: method)
    }
   
    func startScan()
    {
        self.scanAllTimer = 0
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

struct DeviceCell: View {
    let device : Device
    let store : DeviceStore
    @Binding var scanning : Bool
    
    @State private var showDeviceDetail = false
    @State private var showDeviceOfflineMsg = false;
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: DeviceDetail(
                    targetDevice: device,
                    deviceNameStr: device.getNameString(),
                    store: store
                ),
                isActive: $showDeviceDetail
            ) {
                EmptyView()
            }
            .hidden()
            
            Button( action: {
                
                if scanning {
                    scanning = false
                    store.stopScan()
                }
                
                print("\(device.deviceName!) is tapped")
                if device.deviceRSSI != Device_Group.NO_SIGNAL {
                    // Device is online: connect via BLE
                    if let peripheral = device.peripheral {
                        store.connect(targetPeripheral: peripheral)
                        // Navigate regardless of whether device is online
                        showDeviceDetail = true
                    }
                }
               else {
                   showDeviceOfflineMsg = true
                }
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
                        if device.deviceRSSI == Device_Group.NO_SIGNAL {
                            Text("offline")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        else
                        {
                            Text("RSSI: \(device.deviceRSSI) dBm")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        Text("  ") // 2 character space
                        
                        Text(alarmStr)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                    }
                }
            }
        }
        .onAppear {
            print(">>> DeviceCell appeared: \(device.getNameString()), ID: \(device.id)")
        }
        .onDisappear {
            print(">>> DeviceCell disappeared: \(device.getNameString()), ID: \(device.id)")
        }
        .alert("Device is Offline ", isPresented: $showDeviceOfflineMsg) {
            Button("OK") { }
        }
    }
}

// This view is for isolating GroupDetails from ContentView so that GroupDetails is not re-created
// when DeviceStore refreshes causing ContentView re-evlaute
// ContentView (@StateObject DeviceStore)
//    └── GroupNavigationLink
//          └── GroupDetails
//                └── DeviceDetail
struct GroupNavigationLink: View {
    let group: Device_Group?
    let store: DeviceStore
    let sortMethod: DeviceStore.DeviceListSortMode?
    @Binding var isActive: Bool

    var body: some View {
        NavigationLink(
            destination: Group {
                if let group = group {
                    GroupDetails(
                        group: group,
                        store: store,
                        sortMethod: sortMethod
                    )
                } else {
                    EmptyView()
                }
            },
            isActive: $isActive
        ) {
            EmptyView()
        }
        .hidden()
    }
}

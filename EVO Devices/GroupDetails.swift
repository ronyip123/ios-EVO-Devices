//
//  GroupDetails.swift
//  EVO Devices
//
//  Created by Ronald Yip on 10/7/26.
//


import SwiftUI

struct GroupDetails: View {
    
    let group: Device_Group
    // no update is required from store into this object so don't need to be an ObservedObject
    // let store: DeviceStore
    // The above comment is no longer true. We now need to get the update of the group flow index command status
    @ObservedObject var store: DeviceStore
    let sortMethod: DeviceStore.DeviceListSortMode?
    
    @State private var groupName: String
    @State private var offLineDeviceCount : Int
    @State private var alarmDeviceCount: Int
    
    @State private var showEditDeviceGroup = false
    @State private var scanningGroup = false
    @State private var scanGroupTimer = 0
    private let scanGroupTimerPublisher =
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let scanGroupProgressView = ProgressView("Tap Stop Scan to stop..");
    @State private var inEditMode = false
    @State private var groupRevision = 0
    @State private var showSendGroupFlowIndex = false;
    
    //*** New Code for Grooup Flow Index
    @State private var showGroupFlowResult = false
    @State private var groupFlowWasRunning = false
    //*** New Code for Group Flow Index ends
    
    // DeviceStore is actually not used in this View. It is passed in so that we can use
    // DeviceCell to display the Group devices in the list
    init(group: Device_Group, store: DeviceStore, sortMethod: DeviceStore.DeviceListSortMode? ) {
        self.group = group
        self.store = store
        self.sortMethod = sortMethod

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
                Text("\(group.devices.count) Controls,").padding(2)
                Text("\(alarmDeviceCount) In Alarm,").padding(2)
                Text("\(offLineDeviceCount) Offline").padding(2)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            HStack{
                Button(action: {
                    //showEditDeviceGroup = true;
                    // start scanning to refresh the discovered devices
                    cleanup()
                    startScan()
                    self.scanningGroup = true
                    inEditMode = true;
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
                        group.reset_All_Devices_Before_Scanning()
                        startScan()
                    }
                    else{
                        stopScan()
                        evaluateaAlarmOfflineCount()
                        sortDevices(sortMethod: sortMethod ?? DeviceStore.DeviceListSortMode.eAlphabeticalOrder)
                        if (inEditMode){
                            showEditDeviceGroup = true
                        }
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
            
            Button(action: {
                showSendGroupFlowIndex = true;
            }){
                Text("Send Group Flow Index")
                    .fontWeight(.bold)
                    .font(.title)
            }
            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(5.0)
            
            //*** New Code for Group Flow Index
            if store.groupFlowTotal > 0 {
                groupFlowProgressView
            }
            //*** New Code for Group Flow Index ends
            
            ZStack{
                // Device list
                List {
                    ForEach(group.devices){device in
                        DeviceCell(device: device, store: store, scanning: $scanningGroup)
                            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .background(device.inRPMAlarm || device.inFilterAlarm ? Color.red : Color.white)
                    }
                }
                .id(groupRevision)
                .refreshable{
                    await MainActor.run {
                        cleanup()
                        self.scanningGroup = true
                        group.reset_All_Devices_Before_Scanning()
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
        .sheet(isPresented: $showSendGroupFlowIndex, content: {
            GroupFlowIndexEdit(showViewState: $showSendGroupFlowIndex, store: store, group: group, groupFlowIndex: Double(group.groupFlowIndex))
                .transition(.slide)
        })
        .sheet(isPresented: $showEditDeviceGroup, content: {
            let combinedDeviceArray = store.devices + group.getOffLineDeviceList()
            EditDeviceGroup(showViewState: $showEditDeviceGroup, store: store, group: group, sortMethod: sortMethod ?? DeviceStore.DeviceListSortMode.eAlphabeticalOrder, combined_store_devices_and_group_offline_devices: combinedDeviceArray)
              //  .animation(.spring())
                .transition(.slide)
                .onDisappear(){
                    inEditMode = false
                    groupRevision += 1
                }
        })
        .navigationTitle("Device Group")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(scanGroupTimerPublisher) { _ in
            if scanningGroup {
                scanGroupTimer += 1
                print(".onReceive: \(scanGroupTimer)")

                if scanGroupTimer >= ContentView.scanTime {
                    scanningGroup = false
                    evaluateaAlarmOfflineCount()
                    stopScan()
                    sortDevices(sortMethod: sortMethod ?? DeviceStore.DeviceListSortMode.eAlphabeticalOrder)
                    if inEditMode{
                        showEditDeviceGroup = true
                    }
                    print(".onReceive: scanGroupTimer = \(scanGroupTimer)")
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
            
            group.groupName = groupName
            store.saveGroups()
        }
        //*** New Code for Group Flow Index
        .onChange(of: store.groupFlowIndexCommandRunning) { isRunning in

            if isRunning {
                groupFlowWasRunning = true
            }
            else if groupFlowWasRunning {
                groupFlowWasRunning = false
                showGroupFlowResult = true
            }
        }
        .alert("Group Flow Index Completed",
               isPresented: $showGroupFlowResult) {

            Button("OK") { }

        } message: {
            Text(groupFlowResultMessage)
        }
    }
    
    private var groupFlowResultMessage: String {

        var message = """
        Total Devices: \(store.groupFlowTotal)
        Successful: \(store.groupFlowCompleted)
        Failed: \(store.groupFlowFailed)
        Offline: \(store.groupFlowSkipped)
        """

        if !store.groupFlowFailedDeviceNames.isEmpty {
            message += "\n\nFailed Devices:\n"
            message += store.groupFlowFailedDeviceNames.joined(separator: "\n")
        }

        if !store.groupFlowOfflineDeviceNames.isEmpty {
            message += "\n\nOffline Devices:\n"
            message += store.groupFlowOfflineDeviceNames.joined(separator: "\n")
        }

        return message
    }
    //*** New Code for Group Flow Index ends
    
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
    
    func evaluateaAlarmOfflineCount()
    {
        alarmDeviceCount = group.devices.filter { device in
                    device.inFilterAlarm || device.inRPMAlarm
                }.count
        offLineDeviceCount = group.devices.filter { device in
                    device.deviceRSSI == Device_Group.NO_SIGNAL
                }.count
    }
    
    func sortDevices(sortMethod: DeviceStore.DeviceListSortMode)
    {
        switch (sortMethod)
        {
            case .eNone:
                // do nothing
                break;
            case .eAlphabeticalOrder:
                print("sort by alphabetucal order")
                group.devices = group.devices.sorted{ $0.getNameString() < $1.getNameString() }
            case .eSignalStrength:
                print("sort by signal strength")
            group.devices = group.devices.sorted{$0.deviceRSSI > $1.deviceRSSI }
        }
    }
    
    //*** New Code for Group Flow Index
    private var groupFlowProgressView: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Group Flow Index Progress")
                .font(.headline)

            ProgressView(
                value: Double(
                    store.groupFlowCompleted +
                    store.groupFlowFailed +
                    store.groupFlowSkipped
                ),
                total: Double(max(store.groupFlowTotal, 1))
            )
            .tint(.green)

            Text(store.groupFlowStatus)
                .font(.subheadline)

        }
    }
    //*** New Code for Group Flow Index ends
}

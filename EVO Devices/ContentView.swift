//
//  ContentView.swift
//  EVO Devices
//
//  Created by Ronald Yip on 4/13/21.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    let scanTime = 30 //seconds
    @StateObject var store = DeviceStore()
    @State private var scanning = false
    @State private var scanTimer = 0
    let scanProgressView = ProgressView("Tap Stop Scan to stop..");
    @State var oneSecTimer: Timer? = nil
    @State var showAbout = false
    
    var body: some View {
        NavigationView{
            ZStack{
                List{
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
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5.0)
                    
                    ForEach(store.devices){device in
                        DeviceCell(device: device, store: store)
                            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .background(device.inAlarm ? Color.red : Color.white)
                    }
                }
                .navigationBarTitle("EVO Devices")
                .navigationBarItems(trailing: Menu {
                    Button ( action: { self.showAbout.toggle() } ){
                        Text("About")
                    }
                } label: {
                     Image(systemName: "ellipsis.circle")
                })
                
                //show progressView only if scanning
                if self.scanning {
                    ProgressView("tap Stop Scan to stop")
                        .accentColor(Color.green)
                        .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                }
            }
            .onAppear(){
                print("ContentView appears")
                cleanup()
                self.scanning = true
                self.scanTimer = 0
                startScan()
            }
            .onDisappear(){
                print("ContentView disappears")
                if scanning {
                    stopScan()
                }
            }
            .sheet(isPresented: $showAbout, content: {
                About(showViewState: $showAbout)
                    .animation(.spring())
                    .transition(.slide)
            })
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

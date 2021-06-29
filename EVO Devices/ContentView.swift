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
    @State private var scanTimer = -1
    let scanProgressView = ProgressView("Tap Stop Scan to stop..");
    @State var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView{
            ZStack{
                List{
                    Button( action:{
                        self.scanning.toggle()
                        if self.scanning {
                            //store.clearStore()
                            startScan()
                            //self.timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
                        }
                        else{
//                            self.timer.upstream.connect().cancel()
//                            self.scanTimer = 0 //reset scantimer
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
                    }
                }
                .navigationBarTitle("EVO Devices")
                
                //show progressView only if scanning
                if self.scanning {
                    ProgressView("tap Stop Scan to stop")
                        .accentColor(Color.green)
                        .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                }
            }
            .onReceive(timer, perform: { _ in
                if scanTimer == -1 {
                    // Immediately terminate timer after launched
                    self.timer.upstream.connect().cancel()
                    scanTimer = 0;
                    scanning = false
                    print(".onReceive: scanTimer = -1")
                }
                else if self.scanTimer < scanTime {
                    self.scanTimer += 1
                    print(".onReceive: \(self.scanTimer)")
                    
                }
                else
                {
                    self.scanning.toggle()
                    self.timer.upstream.connect().cancel()
                    self.scanTimer = 0
                    print(".onReceive: scanTimer = 30")
                }
             })
            .onAppear(){
                print("ContentView appears")
                scanning.toggle()
                startScan()
            }
            .onDisappear(){
                print("ContentView disappears")
                if scanning {
                    scanning.toggle()
                    //self.timer.upstream.connect().cancel()
                    stopScan()
                }
            }
        }
    }

   
    func startScan()
    {
        store.clearStore()
        self.timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
        store.startScan()
    }

    func stopScan()
    {
        self.timer.upstream.connect().cancel()
        self.scanTimer = 0 //reset scantimer
        store.stopScan()
    }
    
    func cleanup()
    {
        print("in cleanup")
        store.clearStore();
//        if scanning {
//            scanning.toggle()
//        }
//        scanning = false
//        self.timer.upstream.connect().cancel()
    }
    
    func getReady() {
//        self.scanTimer = scanTime
    }
}


struct DeviceCell: View {
    let device : Device
    let store : DeviceStore
    var body: some View {
        NavigationLink(destination: DeviceDetail(targetDevice: device, deviceNameStr: device.getNameString(), store: store)){
            VStack(alignment: .leading){
                Text(device.getNameString())
                    .font(.headline)
                Text("RSSI: \(device.deviceRSSI) dBm")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

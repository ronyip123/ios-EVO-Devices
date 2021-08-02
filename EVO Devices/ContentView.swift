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
    @State var showAbout = false
    
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
                cleanup()
                scanning.toggle()
                startScan()
            }
            .onDisappear(){
                print("ContentView disappears")
                if scanning {
                    scanning.toggle()
                    //self.timer.upstream.connect().cancel()
                    stopScan()
                    cleanup()
                }
            }
            .sheet(isPresented: $showAbout, content: {
                About(showViewState: $showAbout)
                    .animation(.spring())
                    .transition(.slide)
            })
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
        self.timer.upstream.connect().cancel()
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

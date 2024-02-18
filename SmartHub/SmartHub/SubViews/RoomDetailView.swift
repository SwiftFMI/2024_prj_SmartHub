//
//  RoomDetailView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 18.02.24.
//

import SwiftUI
import CodeScanner

struct RoomDetailView: View {
    @EnvironmentObject var homeScreenViewModel: HomeScreenViewModel
    @EnvironmentObject var viewModel: MainViewModel
    
    @State private var isShowingScanner = false
    @State private var isShowingManualInputAllert = false
    @State var newDeviceUUID = ""
    @State var newDeviceName = ""
    @State var newDeviceType: DeviceType = .unknown
    
    var room: Room
    let columns = [
        GridItem(.flexible())
      
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                ForEach(room.devices) { device in
                    DeviceDetailView(device: device)
                        .onTapGesture {
                            // Make sure 'device' is mutable by declaring it as a 'var'
                            var mutableDevice = device
                            mutableDevice.isOn.toggle()
                            // Now you can use 'mutableDevice' to toggle 'isOn' property
                            // Update the 'rooms' array with the updated 'device'
                            homeScreenViewModel.updateDeviceInRoom(room: room, updatedDevice: mutableDevice)
                        }
                }
            }
            .padding()
        }
        .navigationBarTitle(room.name, displayMode: .inline)
        .toolbar {
            Menu {
                Section(room.name){
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Add Device QR", systemImage:"qrcode.viewfinder")
                    }
                    
                    Button {
                        isShowingManualInputAllert = true
                    } label: {
                        Label("Add Device Manual", systemImage:"square.and.pencil")
                    }
                }
            } label: {
                Label("more", systemImage: "ellipsis.circle")
            }
        }
        .sheet(isPresented:$isShowingScanner){
            CodeScannerView(codeTypes: [.qr], completion: handleScan)
        }
        .sheet(isPresented: $isShowingManualInputAllert) {

            Spacer()
            VStack{
                Text("Add device parameters manualy")
                    .font(.title2)
                TextField("Enter device UUID", text: $newDeviceUUID)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                TextField("Enter device name", text: $newDeviceName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                Picker("Device Type", selection: $newDeviceType) {
                    ForEach(DeviceType.allCases) { type in
                        Text(type.rawValue)
                        
                    }
                }.pickerStyle(.segmented)
                
            }
            .padding()
            Spacer()
            Button("Submit", action: submitNewDevice)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
    
    func submitNewDevice(){
        let newDevice = Device(id: newDeviceUUID, name: newDeviceName, type: newDeviceType, isOn: false)
     
        homeScreenViewModel.addDeviceToRoom(room: room.self, device: newDevice, userID: viewModel.currentUser!.uid)
    }
    
    func handleScan (result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string
            print(details)
            
            //let device = Device(name: details)
            //homeScreenViewModel.addDeviceToRoom(room: Room.allRooms.first!, device: device)
            //continue implementation next time
            //we can crete codes with the data separated by symbol
        case .failure(_):
            print("Scanning faild")
        }
    }
}

#Preview {
    NavigationView{
        RoomDetailView(room: Room.allRooms.first!)
    }
}

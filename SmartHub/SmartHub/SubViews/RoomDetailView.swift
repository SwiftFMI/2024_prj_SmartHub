//
//  RoomDetailView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 18.02.24.
//
import Foundation
import SwiftUI
import CodeScanner

struct RoomDetailView: View {
    @EnvironmentObject var homeScreenViewModel: HomeScreenViewModel
    @EnvironmentObject var viewModel: MainViewModel
    
    @State private var isShowingScanner = false
    @State private var isShowingManualInputAllert = false
    @State private var isShowingConfirmationForDelete = false
    @State private var isShowingConfirmationForDeletingDevice = false
    @State private var isShowCancelButtonForRemovingDevices = false
    @State private var isShowingChartSheet = false
    @State private var isWiggliing = false
    @State private var newDeviceUUID = ""
    @State private var newDeviceName = ""
    @State private var newDeviceType: DeviceType = .unknown
    @State private var deviceToBeDeleted: Device? = nil
    
    let screenWidth = UIScreen.main.bounds.width
    
    var room: Room
    
    let columns = [GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            VStack{
                ForEach(room.devices) { device in
                    if isWiggliing {
                        ZStack{
                            Button {
                                isWiggliing = false
                                isShowingConfirmationForDeletingDevice.toggle()
                                isShowCancelButtonForRemovingDevices.toggle()
                                deviceToBeDeleted = device
                            } label:{
                                Image(systemName: "minus.circle.fill")
                            }
                            .font(.title)
                            .foregroundColor(Color(.systemRed))
                            .offset(x: -(screenWidth/2) + 15, y: -40)

                            HStack{
                                DeviceDetailView(device: device)
                                    .onTapGesture {
                                        var mutableDevice = device
                                        mutableDevice.isOn.toggle()
                                        homeScreenViewModel.updateDeviceInRoom(room: room, updatedDevice: mutableDevice)
                                    }
                                Spacer()
                            }
                        }.wiggling()
                    } else {
                        ZStack{
                            HStack{
                                DeviceDetailView(device: device)
                                    .onTapGesture {
                                        var mutableDevice = device
                                        mutableDevice.isOn.toggle()
                                        homeScreenViewModel.updateDeviceInRoom(room: room, updatedDevice: mutableDevice)
                                    }
                                    .onLongPressGesture{
                                        isShowingChartSheet.toggle()
                                    }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle(room.name, displayMode: .inline)
        .toolbar {
            if isShowCancelButtonForRemovingDevices{
                Button{
                    isWiggliing.toggle()
                    isShowCancelButtonForRemovingDevices.toggle()
                } label:{
                    Text("Cancel")
                }
            }
            
            Menu {
                Section(room.name){
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Add Device with QR", systemImage:"qrcode.viewfinder")
                    }
                    
                    Button {
                        isShowingManualInputAllert = true
                    } label: {
                        Label("Add Device Manual", systemImage:"square.and.pencil")
                    }
                    
                    Divider()
                    
                    Button (role: .destructive){
                        isWiggliing.toggle()
                        isShowCancelButtonForRemovingDevices.toggle()
                    }label: {
                        Label("Remove devices", systemImage:"minus.circle")
                    }
                    
                    Button (role: .destructive){
                        isShowingConfirmationForDelete = true
                    } label: {
                        Label("Delete room", systemImage:"trash.slash")
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
            HStack(alignment:.center){
                
                Image(systemName: "square.and.pencil")
                    .font(.title)
                Text("Add device")
                    .font(.title)
                Spacer()
                Button("Cancel") {
                    isShowingManualInputAllert = false
                }
                .padding()
                .cornerRadius(10)
            }.padding()
            
            Spacer()
            
            VStack(alignment:.leading){
                Section(header: Text("Add device parameters manualy")) {
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
                    }
                    .pickerStyle(.wheel)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
            
            Spacer()
            
            Button("Submit new device", action: submitNewDevice)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .disabled(!isValidDevice())
        }
        .sheet(isPresented: $isShowingChartSheet) {
            ConsumtionChartView(isPresented: $isShowingChartSheet)
        }
        .confirmationDialog( "Are you sure you want to delete " + room.name + " ?", isPresented: $isShowingConfirmationForDelete, titleVisibility: .visible) {
            Button (role: .destructive) {
                homeScreenViewModel.deleteRoom(room: self.room, userID: viewModel.currentUser!.uid)
            } label: {
                Text ("Delete")
            }
        }
        .confirmationDialog( "Are you sure you want to delete this device", isPresented: $isShowingConfirmationForDeletingDevice, titleVisibility: .visible) {
            Button (role: .destructive) {
                homeScreenViewModel.deleteDevice(room: self.room, device: deviceToBeDeleted!, userID: viewModel.currentUser!.uid)
                deviceToBeDeleted = nil
            } label: {
                Text ("Delete")
            }
        }
    }
    

    private func isValidDevice() -> Bool {
        return !newDeviceUUID.isEmpty && !newDeviceName.isEmpty
    }
    
    func submitNewDevice(){
        let newDevice = Device(id: newDeviceUUID, name: newDeviceName, type: newDeviceType, isOn: false)
        
        homeScreenViewModel.addDeviceToRoom(room: room.self, device: newDevice, userID: viewModel.currentUser!.uid)
        
        isShowingManualInputAllert = false
    }
    
    func handleScan (result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string
            let jsonString = details
            
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    let deviceData = try decoder.decode(Device.self, from: jsonData)
                    
                    homeScreenViewModel.addDeviceToRoom(room: room.self, device: deviceData, userID: viewModel.currentUser!.uid)
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
                print("Failed to convert JSON string to data")
            }
            
        case .failure(_):
            print("Scanning faild")
        }
    }
}

#Preview {
    NavigationView{
        RoomDetailView(room: Room.allRooms[1])
    }
}

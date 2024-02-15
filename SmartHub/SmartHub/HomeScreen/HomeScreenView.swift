//
//  HomeScreenView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 1.02.24.
//
import SwiftUI
import FirebaseAuth
import CodeScanner

struct HomeScreenView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @ObservedObject var homeScreenViewModel = HomeScreenViewModel()
    @State private var isShowingScanner = false
    @State private var isShowingConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading){
                    ForEach(homeScreenViewModel.rooms) { room in
                        NavigationLink {
                            RoomDetailView(room: room)
                        } label:{
                            RoomTileView(room: room)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Smart Home")
            .toolbar {
                Menu {
                    Section("Home"){
                        Button {
                            isShowingScanner = true
                        } label: {
                            Label("Add Device", systemImage:"qrcode.viewfinder")
                        }
                        
                        Button {
                            //homeScreenViewModel.addRoom(room: temp)
                            //to do
                        } label: {
                            Label("Add Room", systemImage: "door.left.hand.closed")
                        }
                    }
                    
                    Divider()
                    
                    Button (role: .destructive){
                        isShowingConfirmation = true
                    } label: {
                        Label("Log Out", systemImage:"person.crop.circle")
                    }
                    
                } label: {
                    Label("more", systemImage: "ellipsis.circle")
                }
            }
            .sheet(isPresented:$isShowingScanner){
                CodeScannerView(codeTypes: [.qr], completion: handleScan)
            }
            .confirmationDialog( "Are you sure you want to log out?", isPresented: $isShowingConfirmation, titleVisibility: .visible) {
                Button (role: .destructive) {
                    logout()
                } label: {
                    Text ("Log Out")
                }
            }
            .onAppear{
                homeScreenViewModel.loadAllRooms()
            }
        }
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
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            viewModel.isLogged = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct RoomTileView: View {
    var room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(room.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            
            ForEach(room.devices) { device in
                DeviceTileView(device: device)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
        
    }
}

struct DeviceTileView: View {
    var device: Device
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
            
            Text(device.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RoomDetailView: View {
    var room: Room
    var body: some View {
        
        VStack {
            Text(room.name)
                .font(.title)
                .padding()
            
            ForEach(room.devices) { device in
                DeviceDetailView(device: device)
            }
        }
        .navigationBarTitle("Room Detail", displayMode: .inline)
    }
}

struct DeviceDetailView: View {
    var device: Device
    
    var body: some View {
        VStack {
            Image(systemName: "lightbulb")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
            
            Text(device.name)
                .font(.headline)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    HomeScreenView()
}

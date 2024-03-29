//
//  HomeScreenView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 1.02.24.
//
import SwiftUI
import FirebaseAuth


struct HomeScreenView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @ObservedObject var homeScreenViewModel = HomeScreenViewModel()
    
    @State private var isShowingConfirmation = false
    @State private var isShowingAddRoomAllert = false
    @State private var isShowingManualInputAllert = false
    @State private var newRoomName = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading){
                    ForEach(homeScreenViewModel.rooms) { room in
                        NavigationLink {
                            RoomDetailView(room: room)
                                .environmentObject(homeScreenViewModel)
                        } label:{
                            RoomTileView(room: room)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Smart Hub")
            .toolbar {
                Menu {
                    Section("Home"){
                        Button {
                            isShowingAddRoomAllert.toggle()
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
            .alert("Room name", isPresented: $isShowingAddRoomAllert) {
                TextField("Enter room name", text: $newRoomName)
                Button("OK", action: submitNewRoom)
            }
            
            .confirmationDialog( "Are you sure you want to log out?", isPresented: $isShowingConfirmation, titleVisibility: .visible) {
                Button (role: .destructive) {
                    logout()
                } label: {
                    Text ("Log Out")
                }
            }
            .onAppear{
                //for preview testing
                //homeScreenViewModel.loadAllRoomsForPreview()
            }
        }
    }
    
    
    func submitNewRoom() {
        
        guard !newRoomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                print("Room name cannot be empty")
                return
        }
        
        let newRoom = Room(id:UUID().uuidString, name: newRoomName, devices: [])
        homeScreenViewModel.addRoom(room: newRoom)
        
        homeScreenViewModel.addRoomToFirestore(room: newRoom, userID: viewModel.currentUser!.uid)
    }
    
    private func logout() {
        do {
            homeScreenViewModel.finalUpdate()
            try Auth.auth().signOut()
            viewModel.isLogged = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeScreenView()
}

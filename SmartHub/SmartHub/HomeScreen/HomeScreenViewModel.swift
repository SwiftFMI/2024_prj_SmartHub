//
//  HomeScreenViewModel.swift
//  SmartHub
//
//  Created by Valentin Iliev on 1.02.24.
//

import Foundation
import Firebase
import FirebaseFirestore

enum DeviceType: String, CaseIterable, Identifiable {
    case unknown
    case lightBulb
    case smartPlug
    var id: Self { self }
}

struct Device: Identifiable {
    let id: String
    var name: String
    var type: DeviceType = DeviceType.unknown
    var isOn: Bool = false
}

struct Room: Identifiable {
    let id = UUID()
    var name: String
    var devices: [Device]
    
    static var allRooms: [Room] {
        [
            Room(name: "Living Room", devices: [Device(id: UUID().uuidString, name: "Smart Bulb", type: .lightBulb, isOn: true), Device(id: UUID().uuidString,name: "Smart Thermostat", type: .smartPlug)]),
            Room(name: "Bedroom", devices: [Device(id: UUID().uuidString,name: "Smart Lamp"), Device(id: UUID().uuidString,name: "Smart Speaker")]),
            Room(name: "Kitchen", devices: [Device(id: UUID().uuidString,name: "Smart Lamp"), Device(id: UUID().uuidString,name: "Smart Lapm")])
        ]
    }
}

class HomeScreenViewModel: ObservableObject{
    @Published var rooms: [Room] = []
    private var hasBeenInitialized = false
    private var db = Firestore.firestore()
    
    func loadRoomsForCurrentUser(userID: String) {
        // Assuming you have a Firestore collection named "users" and each user document has a "rooms" subcollection
        let userDocRef = db.collection("homes").document(userID)
        let roomsCollectionRef = userDocRef.collection("rooms")
        
        roomsCollectionRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching rooms: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No rooms found")
                return
            }
            
            self.rooms = documents.compactMap { document in
                let roomData = document.data()
                let roomName = roomData["name"] as? String ?? ""
                let devicesData = roomData["devices"] as? [[String: Any]] ?? []
                let devices = devicesData.compactMap { deviceData in
                    let deviceId = deviceData["id"] as? String ?? ""
                    let deviceName = deviceData["name"] as? String ?? ""
                    return Device( id: deviceId, name: deviceName)
                }
                return Room(name: roomName, devices: devices)
            }
        }
    }
    
    // Method to add a new room to Firestore
    func addRoomToFirestore(room: Room, userID: String) {
        let roomData: [String: Any] = [
            "name": room.name,
            "devices": room.devices.map { device in
                ["id": device.id,"name": device.name]
            }
        ]
        
        let userDocRef = db.collection("homes").document(userID)
        
        userDocRef.collection("rooms").addDocument(data: roomData) { error in
            if let error = error {
                print("Error adding room to Firestore: \(error.localizedDescription)")
            } else {
                print("Room added to Firestore successfully")
            }
        }
    }
    
    func loadAllRooms() {
        if hasBeenInitialized {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            self?.rooms.append(contentsOf: Room.allRooms)
            self?.hasBeenInitialized = true
        })
    }
    
    //test function
    func addDeviceToRoom(room: Room, device: Device,userID: String){
        guard let index = rooms.firstIndex(where: { $0.id == room.id }) else {
            return
        }
        
        var updatedRoom = room
        
        let userDocRef = db.collection("homes").document(userID)
        let roomDocRef = userDocRef.collection("rooms").document(room.id.uuidString)
        
        roomDocRef.updateData(["devices": updatedRoom.devices.map { ["id": $0.id, "name": $0.name] }]) { error in
            if let error = error {
                print("Error updating room in Firestore: \(error.localizedDescription)")
            } else {
                print("Room updated in Firestore successfully")
            }
        }
        
        
        updatedRoom.devices.append(device)
        rooms[index] = updatedRoom
    }
    
    func addRoom(room: Room) {
        self.rooms.append(room)
    }
    
    func removeRoom(indexSet: IndexSet) {
        self.rooms.remove(atOffsets: indexSet)
    }
}

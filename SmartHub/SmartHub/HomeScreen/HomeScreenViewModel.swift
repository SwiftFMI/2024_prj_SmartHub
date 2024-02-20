//
//  HomeScreenViewModel.swift
//  SmartHub
//
//  Created by Valentin Iliev on 1.02.24.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI

//QR-code test
//{
//    "id": "12345",
//    "name": "Smart Bulb",
//    "type": "Light Bulb",
//    "isOn": true
//}

enum DeviceType: String, CaseIterable, Identifiable, Codable {
    case unknown = "Default"
    case lightBulb = "Light Bulb"
    case smartPlug = "Smart Plug"
    var id: Self { self }
}

struct Device: Identifiable, Codable {
    let id: String
    var name: String
    var type: DeviceType = DeviceType.unknown
    var isOn: Bool = false
}

struct Room: Identifiable {
    let id: String
    var name: String
    var devices: [Device]
    
    static var allRooms: [Room] {
        [
            Room(id:"01", name: "Living Room", devices: [Device(id: UUID().uuidString, name: "Smart Bulb", type: .lightBulb, isOn: true), Device(id: UUID().uuidString,name: "Smart Thermostat", type: .smartPlug)]),
            Room(id:"02",name: "Bedroom", devices: [Device(id: UUID().uuidString,name: "Smart Lamp", type: .smartPlug, isOn: true), Device(id: UUID().uuidString,name: "Smart Speaker", type: .lightBulb, isOn: true)]),
            Room(id:"03",name: "Kitchen", devices: [Device(id: UUID().uuidString,name: "Smart Lamp", type: .lightBulb, isOn: true), Device(id: UUID().uuidString,name: "Smart Lapm", type: .smartPlug, isOn: true)])
        ]
    }
}


class HomeScreenViewModel: ObservableObject{
    @Published var rooms: [Room] = []
    private var hasBeenInitialized = false
    private var db = Firestore.firestore()
    private var userId: String = ""
    
    init() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            self.userId = userID
            loadRoomsForCurrentUser(userID: userID)
        } else {
            // Handle the case where the current user is not available
            print("No current user")
        }
        
    }
    
    func loadRoomsForCurrentUser(userID: String) {
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
                    let deviceType = deviceData["type"] as? String ?? DeviceType.unknown.rawValue
                    let deviceIsOn = deviceData["isOn"] as? Bool ?? false
                    return Device( id: deviceId, name: deviceName,type: DeviceType(rawValue: deviceType)! ,isOn: deviceIsOn)
                }
                
                return Room(id:document.documentID, name: roomName, devices: devices)
            }
        }
    }
    
    func addRoom(room: Room) {
        self.rooms.append(room)
    }
    
    // Method to add a new room to Firestore
    func addRoomToFirestore(room: Room, userID: String) {
        let roomData: [String: Any] = [
            "name": room.name,
            "devices": room.devices.map { device in
                ["id": device.id,"name": device.name,"type": device.type.rawValue, "isOn": device.isOn]
            }
        ]
        
        let newDocRef = db.collection("homes").document(userID).collection("rooms").document(room.id)
        
        newDocRef.setData(roomData) { error in
            if let error = error {
                print("Error adding room to Firestore: \(error.localizedDescription)")
            } else {
                print("Room added to Firestore successfully")
            }
        }
    }
    
    //test function
    func addDeviceToRoom(room: Room, device: Device, userID: String) {
        guard let index = rooms.firstIndex(where: { $0.id == room.id }) else {
            return
        }
        
        var updatedRoom = room
        
        // Append the new device to the devices array of the room
        updatedRoom.devices.append(device)
        
        // Update Firestore with the new devices array
        let userDocRef = db.collection("homes").document(userID)
        let roomDocRef = userDocRef.collection("rooms").document(room.id)
        //print("Room id " + room.id.uuidString)
        
        roomDocRef.updateData(["devices": updatedRoom.devices.map { ["id": $0.id, "name": $0.name,"type": $0.type.rawValue,"isOn": $0.isOn] }]) { error in
            if let error = error {
                print("Error updating room in Firestore: \(error.localizedDescription)")
            } else {
                print("Room updated in Firestore successfully")
            }
        }
        
        // Update the local rooms array
        rooms[index] = updatedRoom
    }
    
    func updateDeviceInRoom(room: Room, updatedDevice: Device) {
        // Find the index of the room in the rooms array
        guard let index = rooms.firstIndex(where: { $0.id == room.id }) else {
            return
        }
        
        // Create a mutable copy of the room
        var updatedRoom = room
        
        // Find the index of the device in the devices array of the room
        guard let deviceIndex = updatedRoom.devices.firstIndex(where: { $0.id == updatedDevice.id }) else {
            return
        }
        
        // Update the device in the room's devices array
        updatedRoom.devices[deviceIndex] = updatedDevice
        
        // Update the room in the rooms array
        rooms[index] = updatedRoom
    }
    
    //updates all states in firebase when person is trying to logout
    func finalUpdate(){
        
        for room in rooms {
            let userDocRef = db.collection("homes").document(self.userId)
            let roomDocRef = userDocRef.collection("rooms").document(room.id)
            
            let roomData: [String: Any] = [
                "name": room.name,
                "devices": room.devices.map { ["id": $0.id, "name": $0.name,"type": $0.type.rawValue,"isOn": $0.isOn] }
            ]
            
            roomDocRef.setData(roomData) { error in
                if let error = error {
                    print("Error updating room in Firestore: \(error.localizedDescription)")
                } else {
                    print("Room updated in Firestore successfully")
                }
            }
        }
    }
    
    func deleteRoom(room: Room, userID: String) {
        // Remove room from local array
        rooms.removeAll(where: { $0.id == room.id })

        // Remove room from Firebase
        let userDocRef = db.collection("homes").document(userID)
        let roomDocRef = userDocRef.collection("rooms").document(room.id)

        roomDocRef.delete { error in
            if let error = error {
                print("Error deleting room from Firestore: \(error.localizedDescription)")
            } else {
                print("Room deleted from Firestore successfully")
            }
        }
    }
    
    func deleteDevice(room: Room, device: Device, userID: String) {
        //remove device localy
        guard let index = rooms.firstIndex(where: { $0.id == room.id }) else {
            return
        }
        var updatedRoom = room
        updatedRoom.devices.removeAll(where: { $0.id == device.id })
        rooms[index] = updatedRoom
        
        //
        
        let userDocRef = db.collection("homes").document(userID)
        let roomDocRef = userDocRef.collection("rooms").document(room.id)

        let updatedDevices = room.devices.filter { $0.id != device.id }
        let updatedDeviceData = updatedDevices.map { ["id": $0.id, "name": $0.name, "type": $0.type.rawValue, "isOn": $0.isOn] }

        roomDocRef.updateData(["devices": updatedDeviceData]) { error in
            if let error = error {
                print("Error updating devices in Firestore: \(error.localizedDescription)")
            } else {
                print("Device deleted from Firestore successfully")
            }
        }
    
    }
    
    //load mock rooms for preview test
    func loadAllRoomsForPreview() {
         if hasBeenInitialized {
             return
         }

         DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
             self?.rooms.append(contentsOf: Room.allRooms)
             self?.hasBeenInitialized = true
         })
     }
}

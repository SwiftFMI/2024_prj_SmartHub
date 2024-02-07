//
//  HomeScreenViewModel.swift
//  SmartHub
//
//  Created by Valentin Iliev on 1.02.24.
//

import Foundation


struct Device: Identifiable {
    let id = UUID()
    var name: String
}

struct Room: Identifiable {
    let id = UUID()
    var name: String
    var devices: [Device]
    
    static var allRooms: [Room] {
        [
            Room(name: "Living Room", devices: [Device(name: "Smart Bulb"), Device(name: "Smart Thermostat")]),
            Room(name: "Bedroom", devices: [Device(name: "Smart Lamp"), Device(name: "Smart Speaker")]),
            Room(name: "Kitchen", devices: [Device(name: "Smart Lamp"), Device(name: "Smart Lapm")])
        ]
    }
}


class HomeScreenViewModel: ObservableObject{
    @Published var rooms: [Room] = []
    private var hasBeenInitialized = false
    
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
    func addDeviceToRoom(room: Room, device: Device){
        guard let index = rooms.firstIndex(where: { $0.id == room.id }) else {
            return
        }
        
        var updatedRoom = room
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

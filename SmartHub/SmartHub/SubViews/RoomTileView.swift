//
//  RoomTileView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 18.02.24.
//

import SwiftUI

struct RoomTileView: View {
    var room: Room
    
    var body: some View {
        HStack( spacing: 8) {
            VStack(alignment: .leading){
                ForEach(room.devices) { device in
                    HStack{
                        switch device.type {
                        case .lightBulb : 
                            Image(systemName: "lightbulb")
                                .foregroundColor(.gray)
                                .frame(width: 25)
                        case .smartPlug :
                            Image(systemName: "powerplug")
                                .foregroundColor(.gray)
                                .frame(width: 25)
                        case .unknown:
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.gray)
                                .frame(width: 25)
                        }
                        Text(device.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            
            Text(room.name)
                .font(.headline)
                .foregroundColor(.primary)
               
            
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    RoomTileView(room: Room.allRooms.first!)
}

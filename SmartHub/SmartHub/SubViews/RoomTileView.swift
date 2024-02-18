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
            Text(room.name)
                .font(.headline)
                .foregroundColor(.primary)
               
            Spacer()
            
            VStack(alignment: .leading){
                ForEach(room.devices) { device in
                    
                    HStack{
                        switch device.type {
                        case .lightBulb : 
                            Image(systemName: "lightbulb")
                                .foregroundColor(.gray)
                        case .smartPlug :
                            Image(systemName: "powerplug")
                                .foregroundColor(.gray)
                        case .unknown:
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        
                        
//                        Image(systemName: device.type == .lightBulb ? "lightbulb" : "powerplug")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 20, height: 20)
//                            .foregroundColor(.blue)
                        
                        Text(device.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
        
    }
}

#Preview {
    RoomTileView(room: Room.allRooms.first!)
}

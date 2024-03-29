//
//  DeviceDetailView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 18.02.24.
//

import SwiftUI

struct DeviceDetailView: View {
    var device: Device
    
    var body: some View {
        HStack {
            HStack{
                switch device.type {
                case .lightBulb :
                    Image(systemName: "lightbulb")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(device.isOn ? .yellow : .gray)
                case .smartPlug :
                    Image(systemName: "powerplug")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(device.isOn ? .yellow : .gray)
                case .unknown:
                    Image(systemName: "exclamationmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(device.isOn ? .yellow : .gray)
                }
            }
            
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
    DeviceDetailView(device: Room.allRooms.first!.devices.first!)
}

//
//  AddManulalDeviceView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 19.02.24.
//

import SwiftUI

struct AddManulalDeviceView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var homeScreenViewModel: HomeScreenViewModel
    @EnvironmentObject var viewModel: MainViewModel
    
    @State var newDeviceUUID = ""
    @State var newDeviceName = ""
    @State var newDeviceType: DeviceType = .unknown
    
    var room: Room
    
    var body: some View {
        NavigationView{
            Spacer()
            
            Form {
                Section(header: Text("Add device parameters manualy")){
                    // Text("Add device parameters manualy")
                    //   .font(.title2)
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
            }
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
        presentationMode.wrappedValue.dismiss()
    }
}



//#Preview {
//    AddManulalDeviceView()
//}

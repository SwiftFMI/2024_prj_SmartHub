//
//  TestBluetooth.swift
//  SmartHub
//
//  Created by Valentin Iliev on 11.02.24.
//

import SwiftUI
import CoreBluetooth


class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.centralManager?.scanForPeripherals(withServices: nil)
        case .poweredOff:
            print("Bluetooth is powered off.")
            // Handle powered off state
        case .resetting:
            print("Bluetooth is resetting.")
            // Handle resetting state
        case .unauthorized:
            print("Bluetooth is unauthorized.")
            // Handle unauthorized state
        case .unsupported:
            print("Bluetooth is unsupported.")
            // Handle unsupported state
        default:
            print("Bluetooth state is unknown.")
            // Handle other states
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
            peripheralNames.append(peripheral.name ?? "Unnamed device")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = peripherals.firstIndex(of: peripheral) {
            peripherals.remove(at: index)
            peripheralNames.remove(at: index)
        }
    }
}

struct TestBluetooth: View {
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()
    
    var body: some View {
        NavigationView {
            List(bluetoothViewModel.peripheralNames, id: \.self) { peripheral in
                Text(peripheral)
            }
            .navigationTitle("Peripherals")
        }
    }
}


//struct TestBluetooth: View {
//    @State private var deviceUUID: String = ""
//    @StateObject private var bluetoothViewModel = BluetoothViewModel()
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("Enter Device UUID", text: $deviceUUID)
//                    .padding()
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                
//                Button("Connect") {
//                    bluetoothViewModel.connectToDevice(with: deviceUUID)
//                }
//                .padding()
//                .disabled(deviceUUID.isEmpty)
//                
//                List(bluetoothViewModel.peripherals, id: \.identifier) { peripheral in
//                    Text(peripheral.name ?? "Unnamed device")
//                }
//
//                .navigationTitle("Peripherals")
//            }
//        }
//    }
//}
//
//class BluetoothViewModel: NSObject, ObservableObject {
//    private var centralManager: CBCentralManager?
//    internal var peripherals: [CBPeripheral] = []
//    private var peripheral: CBPeripheral?
//    private var lightBulbCharacteristic: CBCharacteristic?
//    @Published var peripheralNames: [String] = []
//    @Published var isLightOn: Bool = false
//    
//    override init() {
//        super.init()
//        self.centralManager = CBCentralManager(delegate: self, queue: .main)
//    }
//    
//    func connectToDevice(with uuid: String) {
//        guard let peripheralUUID = UUID(uuidString: uuid) else {
//            print("Invalid UUID")
//            return
//        }
//        let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "1111")])
//        if let peripheral = connectedPeripherals?.first(where: { $0.identifier == peripheralUUID }) {
//            self.peripheral = peripheral
//            peripheral.delegate = self
//            centralManager?.connect(peripheral, options: nil)
//        } else {
//            print("Peripheral not found")
//        }
//    }
//}
//
//extension BluetoothViewModel: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        switch central.state {
//        case .poweredOn:
//            centralManager?.scanForPeripherals(withServices: nil)
//        case .poweredOff:
//            print("Bluetooth is powered off.")
//            // Handle powered off state
//        case .resetting:
//            print("Bluetooth is resetting.")
//            // Handle resetting state
//        case .unauthorized:
//            print("Bluetooth is unauthorized.")
//            // Handle unauthorized state
//        case .unsupported:
//            print("Bluetooth is unsupported.")
//            // Handle unsupported state
//        default:
//            print("Bluetooth state is unknown.")
//            // Handle other states
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
//                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        if !peripherals.contains(peripheral) {
//            peripherals.append(peripheral)
//            peripheralNames.append(peripheral.name ?? "Unnamed device")
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        peripheral.delegate = self
//        peripheral.discoverServices(nil)
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        if let index = peripherals.firstIndex(of: peripheral) {
//            peripherals.remove(at: index)
//            peripheralNames.remove(at: index)
//        }
//    }
//}
//
//extension BluetoothViewModel: CBPeripheralDelegate {
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else { return }
//        for service in services {
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else { return }
//        for characteristic in characteristics {
//            if characteristic.uuid == CBUUID(string: "84FD5AAF-1ED0-444A-A485-785AF0652194") {
//                lightBulbCharacteristic = characteristic
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        guard characteristic.uuid == lightBulbCharacteristic?.uuid,
//              let data = characteristic.value,
//              let value = data.first else { return }
//        
//        isLightOn = (value == 0x01)
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            print("Error writing characteristic value: \(error.localizedDescription)")
//        } else {
//            print("Successfully wrote characteristic value")
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            print("Error updating notification state: \(error.localizedDescription)")
//        } else {
//            print("Successfully updated notification state")
//        }
//    }
//}


#Preview {
    TestBluetooth()
}


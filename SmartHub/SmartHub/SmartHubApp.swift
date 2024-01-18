//
//  SmartHubApp.swift
//  SmartHub
//
//  Created by vnc003 on 18.01.24.
//

import SwiftUI

@main
struct SmartHubApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

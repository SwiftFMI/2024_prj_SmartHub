//
//  SmartHubApp.swift
//  SmartHub
//
//  Created by vnc003 on 18.01.24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct SmartHubApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
            //            ContentView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

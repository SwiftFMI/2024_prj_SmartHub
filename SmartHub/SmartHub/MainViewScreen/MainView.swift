//
//  MainView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 28.01.24.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var mainViewModel = MainViewModel()
    
    var body: some View {
        if mainViewModel.isLogged {
            ContentView()
                .environmentObject(mainViewModel)
        } else {
            LogInView()
                .environmentObject(mainViewModel)
        }
        
    }
}

#Preview {
    MainView()
}

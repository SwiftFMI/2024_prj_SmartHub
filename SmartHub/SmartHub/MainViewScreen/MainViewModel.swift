//
//  MainViewModel.swift
//  SmartHub
//
//  Created by Valentin Iliev on 28.01.24.
//

import Foundation
import FirebaseAuth


class MainViewModel: ObservableObject {
    @Published var isLogged = false
    @Published var currentUser: User?
}


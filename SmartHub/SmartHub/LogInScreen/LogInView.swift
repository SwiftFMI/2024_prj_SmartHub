//
//  LogInView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 28.01.24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct LogInView: View {
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var verifyPassword = ""
    @State private var loginStatusMessage = ""
    
    @EnvironmentObject private var viewModel: MainViewModel
    //comment
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "homekit")
                .font(.system(size: 65))
            
            Text("Smart Hub")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            
            Picker(selection: $isLoginMode, label: Text("Picker here")) {
                Text("Login")
                    .tag(true)
                Text("Create Account")
                    .tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Group {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(12)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                SecureField("Password", text: $password)
                    .padding(12)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                if !isLoginMode {
                    SecureField("Verify Password", text: $verifyPassword)
                        .padding(12)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            
            Button {
                handleAction()
            } label: {
                HStack {
                    Spacer()
                    Text(isLoginMode ? "Log In" : "Create Account")
                        .foregroundColor(Color.white)
                        .padding(.vertical, 10)
                        .font(.system(size: 20, weight: .semibold))
                    Spacer()
                }
                .background(Color.blue)
                .cornerRadius(50)
            }
            
            Text(loginStatusMessage)
                .foregroundColor(.red)
        }
        .padding()
    }
    
    private func handleAction() {
        if isLoginMode {
            signIn()
            print(loginStatusMessage)
        } else {
            createAccount()
            print(loginStatusMessage)
        }
    }
    
    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                loginStatusMessage = "Error: \(error.localizedDescription)"
            } else {
                loginStatusMessage = "Login successful"
                viewModel.isLogged = true
                if let user = Auth.auth().currentUser {
                    viewModel.currentUser = user
                } else {
                    viewModel.currentUser = nil
                }
            }
        }
    }
    
    // Function to create a new collection for the user's home UUID
    func addUserToHomesCollection(userID: String) {
        let db = Firestore.firestore()
        let homesCollection = db.collection("homes")
        
        // Add a new document with the user's ID as the document ID
        homesCollection.document(userID).setData(["userUUID": userID]) { error in
            if let error = error {
                print("Error adding user to homes collection: \(error.localizedDescription)")
            } else {
                print("User added to homes collection successfully")
            }
        }
    }
    
    private func createAccount() {
        guard password == verifyPassword else {
            loginStatusMessage = "Error: Passwords do not match"
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                loginStatusMessage = "Error: \(error.localizedDescription)"
            } else {
                loginStatusMessage = "Account created successfully"
                if let user = result?.user {
                    // Successfully registered user
                    print("User registered with UUID: \(user.uid)")
                    
                    // Create a home collection for the user
                    addUserToHomesCollection(userID: user.uid)
                    
                    // Create a rooms subcollection for the user
                    //addRoomsSubcollectionForUser(userID: user.uid)
                    
                    // Sign in the user
                    signIn()
                }
            }
        }
    }

    // Function to create a new subcollection called "rooms" for the user
//    func addRoomsSubcollectionForUser(userID: String) {
//        let db = Firestore.firestore()
//        let homesCollection = db.collection("homes")
//        
//        // Reference to the user's document in the "homes" collection
//        let userDocRef = homesCollection.document(userID)
//        
//        // Reference to the "rooms" subcollection for the user's document
//        let roomsCollection = userDocRef.collection("rooms")
//        
//        // Add a placeholder document to the "rooms" subcollection
////        roomsCollection.addDocument(data: [
////            "name": "blank"
////        ]) { error in
////            if let error = error {
////                print("Error adding document to rooms subcollection: \(error.localizedDescription)")
////            } else {
////                print("Subcollection 'rooms' created for user with ID: \(userID)")
////            }
////        }
//    }

    
}

#Preview {
    LogInView()
}

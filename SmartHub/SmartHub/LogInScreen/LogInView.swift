//
//  LogInView.swift
//  SmartHub
//
//  Created by Valentin Iliev on 28.01.24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LogInView: View {
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var verifyPassword = ""
    @State private var loginStatusMessage = ""
    
    @EnvironmentObject private var viewModel: MainViewModel
    
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
            }
        }
    }
    
}

#Preview {
    LogInView()
}

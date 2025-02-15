//
//  ContentView.swift
//  DopamineFriends
//
//  Created by joki on 09.02.25.
//


// await: it uses to pause the execution until async function is completely runned

//task: unit of work that can be executed concurrently or asynchronously
//- structured task: Ensure completion before the scope exits. Used with async and await 
import SwiftUI
import Foundation

struct ContentView: View {
    @State private var isLogginIn = false
    @ObservedObject var privyManager: PrivyManager
    @State private var email = ""
    @State private var otp = ""
    @State private var showEmailInput = false
    @State private var tokenstate = false
    @State private var showTokenStateSheet = false
    @State private var activeSheet: ActiveSheet? = nil
    
    
    var body : some View {
        VStack {
            if privyManager.isLoading {
                ProgressView()
            } else if case .authenticated = privyManager.authState {
                    BettingDetailView()
            } else {
                Button {
                    privyManager.signInWithApple()
                } label : {
                    Text ("Login with Apple")
                }
                
                Button {
                    activeSheet = .emailInput
                } label: {
                    HStack {
                        Text("Sign in with Email")
                    }
                }
            }
        }.sheet(isPresented: $showEmailInput) {
            EmailEntryView(email: $email) {
                Task {
                    let tokenState  = await privyManager.signInWithEmail(email: email)
                    showEmailInput = false
                    
                    if tokenstate {
                        showTokenStateSheet = true
                    }
                }
            }
        }.sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .emailInput:
                EmailEntryView(email: $email) {
                    Task {
                        let tokenState = await privyManager.signInWithEmail(email: email)
                        if tokenState {
                            activeSheet = .tokenState
                        } else {
                            activeSheet = nil
                        }
                    }
                }
            case .tokenState:
                TokenStateView(otp: $otp) {
                    Task {
                        let authState = await privyManager.signWithEmailOTP(email: email, otp: otp)
                        activeSheet = nil
                        
                        if case .authenticated = authState {
                            print("User authenticated")
                        }
                    }
                }
            }
        }
    }
}

enum ActiveSheet: Identifiable {
    case emailInput
    case tokenState

    var id: Int {
        hashValue
    }
}

struct EmailEntryView: View {
    @Binding var email: String
    var onSignIn: () -> Void
    
    var body: some View {
        VStack {
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button("Continue") {
                guard !email.isEmpty else { return }
                onSignIn()
            }
            .disabled(email.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            print("EmailEntryView works")
        }
    }
}

struct TokenStateView: View {
    @Binding var otp: String
    var onOTP: () -> Void

    var body: some View {
        VStack {
            TextField("Enter OTP", text: $otp)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            Button("Continue") {
                guard !otp.isEmpty else { return }
                onOTP()
            }
            .disabled(otp.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

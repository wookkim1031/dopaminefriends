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
import PrivySDK
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isLogginIn = false
    @State private var isLoggingOut = false
    @State private var selectedChain = SupportedChain.sepolia
    @StateObject var privyManager: PrivyManager
    @State private var email = ""
    @State private var otp = ""
    @State private var showEmailInput = false
    @State private var tokenstate = false
    @State private var showTokenStateSheet = false
    @State private var activeSheet: ActiveSheet? = nil
    @State private var navigateToProfile = false
    
    var body : some View {
        NavigationView {
            VStack {
                if privyManager.isLoading {
                    ProgressView()
                } else if case .authenticated = privyManager.authState {
                    if privyManager.isLoading {
                        ProgressView("Creating Wallet...")
                    } else if let address = privyManager.selectedWallet?.address {
                        BettingListView()
                        NavigationLink(destination: CreateBettingView(privyManager: privyManager)) {
                            Text("Create a bet")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        NavigationLink(destination: ProfileView(privyManager: privyManager)) {
                            Text("Profile")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
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
            }.onChange(of: privyManager.authState) { newState in
                if case .authenticated = newState {
                    privyManager.createSolanaWallet() // Auto-create wallet when authenticated
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

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

struct ContentView: View {
    @State private var isLogginIn = false
    @State private var isLoggingOut = false
    @State private var selectedChain = SupportedChain.sepolia
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
                Button{
                    privyManager.signOut()
                } label: {
                    Text("Sign out")
                }
                Button {
                    privyManager.createSolanaWallet()
                } label : {
                    Text ("Create Solana wallet")
                }
                Button {
                    privyManager.createETHWallet()
                } label : {
                    Text ("Create ETH wallet")
                }
                Button {
                    privyManager.signSolanaMessage()
                } label : {
                    Text ("Sign solana message")
                }
                Button {
                    privyManager.signETHMessage()
                } label : {
                    Text ("Sign eth message")
                }
                switch privyManager.embeddedWalletState {
                    case .connecting:
                        ConnectingView()
                        .onAppear {
                                        print("Connecting!")
                                    }
                    case .connected:
                        connectedView()
                        .onAppear {
                                        print("Connected!")
                                    }
                    case .error:
                        Text("Error on connecting wallet")
                    @unknown default:
                        EmptyView()
                        .onAppear {
                                        print("Empty View!")
                                    }
                }
            } else {
                Button {
                    privyManager.signInWithApple()
                } label : {
                    Text ("Sign in with Apple")
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

extension ContentView {
    @ViewBuilder
    func ConnectingView() -> some View {
        VStack {
            Text("Connecting Wallet")
            
        }
    }
    
    @ViewBuilder
    func connectedView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(SupportedChain.allCases, id: \.self) { chain in
                    RadioButtonHelper(
                        chain: chain,
                        selectedNetwork: $selectedChain
                    )
                }
            }
        }
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("State: ")
                Text("\(privyManager.embeddedWalletState.toString)").fontWeight(.light)
            }
            HStack {
                Text("Chain: ")
                // returns the text as it is. As the verbatim argument
                Text(verbatim: "\(privyManager.chain.chainInfo.id) (\(privyManager.chain.chainInfo.name)").fontWeight(.light)
            }
            HStack {
                Text("Balance: ")
                Text("\(privyManager.balance) \(privyManager.chain.chainInfo.nativeCurrency.symbol)").fontWeight(.light)
            }
            HStack {
                Text("Address: ")
                if let address = privyManager.selectedWallet?.address {
                    Text("0x...\(String(address.suffix(8)))").fontWeight(.light).onAppear{
                        print("0x...\(String(address.suffix(8)))")
                    }
                } else {
                    Text("N/A ").fontWeight(.light)
                }
            }
            HStack{
                Text("Send Transaction: ")
                if let address = privyManager.selectedWallet?.address {
                    Button {
                        Task {
                                do {
                                    try await privyManager.sendTransaction(address: address, amount: "3000")
                                } catch {
                                    print("Failed to send transaction: \(error)")
                                }
                            }
                    } label : {
                        Text ("Send Transaction")
                    }
                } else {
                    Text("N/A")
                }
            }
        }
    }
}

//
//  ProfileView.swift
//  DopamineFriends
//
//  Created by joki on 18.02.25.
//

import Foundation
import SwiftUI
import PrivySDK

struct ProfileView: View {
    @StateObject var privyManager: PrivyManager
    @State private var selectedChain = SupportedChain.sepolia
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.blue)
                    .frame(width: 125, height: 125)
                    .padding()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Address: ")
                        Text(privyManager.selectedWallet!.address)
                    }
                    HStack {
                        Text("Wallet Address: ")
                        if let address = privyManager.selectedWallet?.address {
                            Text("0x...\(String(address.suffix(8)))").onAppear{
                                print("0x...\(String(address.suffix(8)))")
                            }
                        } else {
                            Text("N/A ")
                        }
                    }
                }
                Button(action: {
                    Task {
                        try? await privyManager.getBalance(address: privyManager.selectedWallet!.address)
                    }
                }) {
                    Text("Get Balance")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button{
                    privyManager.signOut()
                } label: {
                    Text("Sign out")
                }
                /*
                Button {
                    privyManager.createETHWallet()
                } label : {
                    Text ("Create ETH wallet")
                }*/
                Button {
                    privyManager.signSolanaMessage()
                } label : {
                    Text ("Sign solana message (Testing use)")
                }
                /*
                Button {
                    privyManager.signETHMessage()
                } label : {
                    Text ("Sign eth message")
                }*/
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
                Spacer()
                
                .navigationTitle("Profile")
            }
        }
    }
}


extension ProfileView {
    @ViewBuilder
    func ConnectingView() -> some View {
        VStack {
            Text("Connecting Wallet")
            
        }
    }
    
    @ViewBuilder
    func connectedView() -> some View {
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
                Text("Switch To Solana Wallet: ")
                if let solanaWallet = privyManager.wallets.first(where: { $0.chainType == .solana }) {
                    Button {
                        Task {
                                do {
                                    privyManager.switchWallet(to: solanaWallet.address)
                                } catch {
                                    print("Failed to send transaction: \(error)")
                                }
                            }
                    } label : {
                        Text ("Switch to Solana Wallet")
                    }
                } else {
                    Text("N/A")
                }
            }
            HStack{
                Text("Send Solana Transaction: ")
                if let address = privyManager.selectedWallet?.address {
                    Button {
                        Task {
                                do {
                                    try await privyManager.sendTransaction(address: address, amount: 300)
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


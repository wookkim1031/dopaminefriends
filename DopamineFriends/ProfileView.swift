//
//  ProfileView.swift
//  DopamineFriends
//
//  Created by joki on 18.02.25.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @ObservedObject var privyManager: PrivyManager
    
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
                        Text("Name: ")
                        Text("Ki Wook Kim")
                    }
                    HStack {
                        Text("Email: ")
                        Text("wook.kim@rwth-aachen.de")
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
                Button("Log Out") {
                    privyManager.signOut()
                }
                .tint(.red)
                
                Spacer()
                
                .navigationTitle("Profile")
            }
        }
    }
}

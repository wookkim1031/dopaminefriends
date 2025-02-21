//
//  RadioButtonHelper.swift
//  DopamineFriends
//
//  Created by joki on 16.02.25.
//

import PrivySDK
import SwiftUI

struct RadioButtonHelper: View {
    let chain: SupportedChain
    @Binding var selectedNetwork: SupportedChain
    
    var body: some View {
        Button {
            self.selectedNetwork = self.chain
        } label: {
            Text(chain.chainInfo.name)
                .padding()
                .foregroundColor(.white)
                .background(selectedNetwork == chain ? .green : .gray)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white))
        }
    }
}


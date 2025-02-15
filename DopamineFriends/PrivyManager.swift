//
//  PrivyManager.swift
//  DopamineFriends
//
//  Created by joki on 11.02.25.
//

import Foundation
import PrivySDK

class PrivyManager : ObservableObject{
    let config = PrivyConfig(appId: "cm70p2l6g0067ii2smm44e3hv", appClientId: "client-WY5gwZdsAXeYgqDUeoD14JqwLppccakqmMCHR34ZTJDGU")
    let privy: Privy
    
    @Published var authState = AuthState.unauthenticated
    @Published var isLoading = false
    
    init() {
        self.privy = PrivySdk.initialize(config: config)
        Task {await configure()}
    }
    
    @MainActor
    func configure() {
        privy.setAuthStateChangeCallback { [weak self] state in
            DispatchQueue.main.async {
                self?.authState = state
            }
        }
    }
    
    @MainActor
    func signInWithApple() {
        isLoading = true
        Task{
            do {
                let authSession = try await privy.oAuth.login(with: .apple)
                print("Login successful: \(authSession)")
            } catch {
                debugPrint("Error Apple \(error)")
            }
            isLoading = false
        }
    }
    
    @MainActor
    func signInWithEmail(email: String) async -> Bool {
        isLoading = true
        do {
            //wait until the async finsihes its job
            let otpSentSuccessfully: Bool = await privy.email.sendCode(to: email)
            isLoading = false
            debugPrint("OTP sign in with email: \(otpSentSuccessfully)")
            return otpSentSuccessfully
        } catch {
            debugPrint("Error sending email: \(error)")
            isLoading = false
            return false
        }
    }
    
    @MainActor
    func signWithEmailOTP(email:String, otp: String) async -> AuthState {
        isLoading=true
            do {
                let authState: AuthState = try await privy.email.loginWithCode(otp, sentTo: email)
                isLoading = false
                return authState
            } catch {
                isLoading = false
                return .unauthenticated
            }
        
    }
}


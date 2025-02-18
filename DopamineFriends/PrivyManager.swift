//
//  PrivyManager.swift
//  DopamineFriends
//
//  Created by joki on 11.02.25.
//

import Foundation
import PrivySDK
import SolanaSwift

class PrivyManager : ObservableObject{
    let config = PrivyConfig(appId: "cm70p2l6g0067ii2smm44e3hv", appClientId: "client-WY5gwZdsAXeYgqDUeoD14JqwLppccakqmMCHR34ZTJDGU")
    let privy: Privy
    let accountStorage = InMemorySolanaTokenListStorage()
    
    @Published var authState = AuthState.unauthenticated
    @Published var isLoading = false
    @Published var chain: SupportedChain = SupportedChain.sepolia
    @Published var balance = "0.00"
    @Published var embeddedWalletState = EmbeddedWalletState.notCreated
    @Published var wallets = [EmbeddedWallet]()
    @Published var selectedWallet: EmbeddedWallet?
    @Published var txs: [String] = []
    
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

        privy.embeddedWallet.setEmbeddedWalletStateChangeCallback { state in
                self.embeddedWalletState = state
            // Go through only if the wallet is connected
                guard case .connected(let wallets) = self.embeddedWalletState else {
                    print("Wallet not connected")
                    return
                }
            //connecting to the wallet
                self.wallets = wallets
                self.selectedWallet = wallets.first
        }
        }
        
        
        @MainActor
        func signOut() {
            isLoading = true
            Task {
                do {
                    let auth = try await privy.logout()
                    authState = .unauthenticated
                    print("Signout Successfully \(auth)")
                } catch {
                    print("Error signing out: \(error)")
                }
                await MainActor.run {
                    isLoading = false
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
            isLoading = true
            do {
                let authState: AuthState = try await privy.email.loginWithCode(otp, sentTo: email)
                isLoading = false
                return authState
            } catch {
                isLoading = false
                return .unauthenticated
            }
        }
    
        @MainActor
        func createETHWallet() {
            isLoading=true
            guard case .authenticated = privy.authState else {
                print("User is not authenticated")
                return
            }
            Task {
                do {
                    // Create the primary (HD index == 0) Ethereum wallet
                    let ethereumWallet = try await privy.embeddedWallet.createWallet(chainType: .ethereum)

                    // Create an additional (HD index == 1) Ethereum wallet
                    // If allowAdditional was unset, or set to false, this method would throw an error
                    let additionalEmbeddedWallet = try await privy.embeddedWallet.createWallet(chainType: .ethereum, allowAdditional: true)
                    print("Create ETH Wallet \(ethereumWallet)")
                    print("Create Wallet \(additionalEmbeddedWallet)")
                } catch {
                    print("Error creating ETH wallet \(error)")
                }
                isLoading = false
            }
        }
        
        @MainActor
        func createSolanaWallet() {
            isLoading=true
            guard case .authenticated = privy.authState else {
                print("User is not authenticated")
                return
            }
            Task {
                do {
                    let solanaEmbeddedWallet = try await privy.embeddedWallet.createWallet(chainType: .solana, allowAdditional: true)
                    let account = try await KeyPair(network: .testnet)
                    //try accountStorage.save(account)
                    isLoading = false
                    print("Create Wallet \(solanaEmbeddedWallet)")
                } catch {
                    isLoading = false
                    print("Error with creating wallet")
                }
            }
        }
        
        @MainActor
        func signETHMessage() {
            Task {
                guard case .connected(let wallets) = privy.embeddedWallet.embeddedWalletState else {
                    print("Wallet not connected")
                    return
                }

                guard let wallet = wallets.first, wallet.chainType == .ethereum else {
                    print("No Ethereum wallets available")
                    return
                }

                // Get the provider for wallet
                let provider = try privy.embeddedWallet.getEthereumProvider(for: wallet.address)

                let signature = try await provider.request(
                    RpcRequest(
                        method: "personal_sign",
                        params: ["This is the message that is being signed", wallet.address]
                    )
                )

                print(signature)
            }
        }
    
        @MainActor
        func signSolanaMessage() {
            Task {
                guard case .connected(let wallets) = privy.embeddedWallet.embeddedWalletState else {
                    print("Wallet not connected")
                    return
                }
                
                guard let wallet = wallets.first, wallet.chainType == .solana else {
                    print("No Solana wallets available")
                    return
                }
                
                // Get the provider for wallet. Wallet chainType MUST be .solana
                let provider = try privy.embeddedWallet.getSolanaProvider(for: wallet.address)
                print("Provider : \(provider)")
                
                
                // Sign a Base64 encoded message
                let signature = try await provider.signMessage(message: "SGVsbG8hIEkgYW0gdGhlIGJhc2U2NCBlbmNvZGVkIG1lc3NhZ2UgdG8gYmUgc2lnbmVkLg==")
                print(signature)
            }
        }
        
    @MainActor
    func sendTransaction(address: String, amount: String) async throws{
        Task {
            do {
                let endpoint = APIEndPoint(address: "https://api.devnet.solana.com", network: .devnet)
                print(endpoint)
                guard case .connected(let wallets) = privy.embeddedWallet.embeddedWalletState else {
                    throw PrivyWalletError.notConnected
                }
                print("check")
                // Replace this with your desired wallet, ensure it's a Solana wallet
                guard let wallet = wallets.first, wallet.chainType == .solana else {
                        print("No Solana wallets available")
                            return
                }
                
                let solana_client = JSONRPCAPIClient(endpoint: endpoint)
                print("check3")
                /*
                guard let account = try? accountStorage.account?.publicKey.base58EncodedString else { throw UnauthorizedError }
                let balance = try await apiClient.getBalance(account: account, commitment: "recent")*/
                
                //testing
                let blockchainClient = BlockchainClient(apiClient: solana_client)
                
                // keypair??
                let WalletPK = try PublicKey(string: wallet.address)
                print(WalletPK)
                
                let transferInstruction = SystemProgram.transferInstruction(
                    from: WalletPK,
                    to: "9NvE68JVWHHHGLp5NNELtM5fiBw6SXHrzqQJjUqaykC1",
                    lamports: 100000000000000
                )
                
                let feePayer = WalletPK
                /*
                let preparedTransaction = try await blockchainClient.prepareTransaction(
                    instructions: [transferInstruction],
                    signers: ,
                    feePayer: feePayer)
                */

                let result = try await solana_client.getBlockHeight()
                print("Block Height \(result)")
                let provider = try privy.embeddedWallet.getSolanaProvider(for: address)
                
                
                let blockChainClient = BlockchainClient(apiClient: solana_client)
                print(blockChainClient)
                
                //signers transaction
                var tx = Transaction()
                tx.instructions.append(SystemProgram.transferInstruction(
                     from: WalletPK,
                     to: try PublicKey(string: "9NvE68JVWHHHGLp5NNELtM5fiBw6SXHrzqQJjUqaykC1"),
                     lamports: 100000000000000
                     )
                )
                //tx.recentBlockhash = latestBlockhash
                tx.feePayer = WalletPK
                
                let message = try tx.compileMessage().serialize().base64EncodedString()
                let signature = try await provider.signMessage(message: message)
                print(signature)

                // Add the signature back to the transaction
                if let signatureData = Data(base64Encoded: signature) {
                    let signature_insert = Signature(signature: signatureData, publicKey: WalletPK) // Ensure this initializer exists
                    try tx.addSignature(signature_insert)
                } else {
                    print("Invalid base64 signature data")
                }
                let transactionId = try await solana_client.sendTransaction(transaction: tx.serialize().base64EncodedString())
                print("Transaction sent successfully! TxID:", transactionId)
                print(tx)
            } catch {
                print("Error while sending transaction \(error)")
            }
        }
    }
}

//
//  DopamineFriendsApp.swift
//  DopamineFriends
//
//  Created by joki on 09.02.25.
//
import FirebaseCore
import SwiftUI

@main
struct DopamineFriendsApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//
//  FirebaseConfig.swift
//  DopamineFriends
//
//  Created by joki on 23.02.25.
//

import Foundation

@main
struct FirebaseConfig: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}

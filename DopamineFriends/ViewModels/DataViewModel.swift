//
//  DataViewModel.swift
//  DopamineFriends
//
//  Created by joki on 23.02.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private var db = Firestore.firestore()

    func fetchTasks() {
        db.collection("tasks").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching tasks: \(error.localizedDescription)")
                return
            }
            
            // Map Firestore documents to Task objects
            self.tasks = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Task.self)
            } ?? []
        }
    }
}

//
//  ProfileViewViewModel.swift
//  DopamineFriends
//
//  Created by joki on 18.02.25.
//

import Foundation

class ProfileViewModel: ObservableObject {
    init() {}
    
    func toggleIsDone(item: ToDoListItem) {
        var itemCopy = item
        itemCopy.setDone(!item.isDone)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
    }
}

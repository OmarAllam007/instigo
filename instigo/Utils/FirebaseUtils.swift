//
//  FirebaseUtils.swift
//  instigo
//
//  Created by Omar Khaled on 23/04/2022.
//

import Foundation
import Firebase

extension Database{
    static func loadUserWithUUID(uuid:String, completion: @escaping (User)->()){
        let usersDBRef = Database.database().reference().child("users").child(uuid)
        usersDBRef.observeSingleEvent(of: .value) { snapshot in
            guard let userDictionary = snapshot.value as? [String:Any]  else { return }
            let user = User(uuid:uuid,dictionary: userDictionary)
            completion(user)
            
        } withCancel: { error in
            print("load user error")
        }
    }
}

//
//  User.swift
//  instigo
//
//  Created by Omar Khaled on 16/04/2022.
//

import Foundation


struct User{
    let uuid:String
    let username:String
    let profileImageUrl:String
    
    init(uuid:String,dictionary:[String:Any]){
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageURL"] as? String ?? ""
        self.uuid = uuid
    }
}

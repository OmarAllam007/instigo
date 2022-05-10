//
//  Comment.swift
//  instigo
//
//  Created by Omar Khaled on 28/04/2022.
//

import Foundation

struct Comment {
    let user:User
    
    let user_id:String
    let text:String
    let created_date:Double
    
    init(user:User,dictionary:[String:Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.user_id = dictionary["user_id"] as? String ?? ""
        self.created_date = dictionary["created_date"] as? Double ?? 0
        self.user = user
    }
}

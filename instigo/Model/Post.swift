//
//  Post.swift
//  instigo
//
//  Created by Omar Khaled on 18/04/2022.
//

import UIKit


struct Post{
    var id:String?
    let user:User
    let imageUrl:String
    let description:String
    let createdDate:Date
    
    var hasLiked = true
    init(user:User,dictionary:[String:Any]) {
        self.imageUrl = dictionary["imageURL"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.user = user
        
        let dateSince1970 = dictionary["created_at"] as? Double ?? 0
        self.createdDate = Date(timeIntervalSince1970: dateSince1970)
    }
    
}

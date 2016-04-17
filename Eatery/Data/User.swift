//
//  User.swift
//  Eatery
//
//  Created by Daniel Li on 4/17/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 The shared instance of User is the current logged-in user.
 */
class User {
    
    /// The User's primary key
    var id: Int
    
    /// The User's first name
    var firstName: String
    
    /// The User's last name
    var lastName: String
    
    /// Number of friends this User has
    var friendsCount: Int
    
    /// Popularity score
    var popularityScore: Int
    
    /// The User's phone number
    var phoneNumber: Int
    
    init(json: JSON) {
        id = json[API.UserId].intValue
        firstName = json[API.UserFirstName].stringValue
        lastName = json[API.UserLastName].stringValue
        friendsCount = json[API.UserFriendsCount].intValue
        popularityScore = json[API.UserPopularity].intValue
        phoneNumber = json[API.UserPhone].intValue
    }
}
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
    
    static let currentUser = User()
    private init() {    }
    
    init(json: JSON) {
        
    }
    
    /// The User's first name
    var fname: String!
    
    /// The User's last name
    var lname: String!
    
    /// The User's handle name
    var handle: String!
    
    /// The User's phone number
    var phoneNumber: Int!
}
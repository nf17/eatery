//
//  BeaconEvent.swift
//  Eatery
//
//  Created by Daniel Li on 4/17/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BeaconEvent {
    
    /// The primary key of this event
    var id: Int
    
    /// The User ID
    var userID: Int
    
    /// Name of this event
    var title: String
    
    /// Whether the event is active or not
    var active: Bool
    
    /// When the event was created
    var creationDate: NSDate
    
    /// When the event was updated
    var updatedDate: NSDate
    
    
    init(json: JSON) {
        id = json[API.EventId].intValue
        userID = json[API.UserId].intValue
        title = json[API.EventTitle].stringValue
        active = json[API.EventActive].boolValue
        
//        let formatter = NSDateFormatter()
//        formatter.dateFormat =
//        creationDate = json[API.EventCreationDate].stringValue
        creationDate = NSDate()
        updatedDate = NSDate()
    }
}
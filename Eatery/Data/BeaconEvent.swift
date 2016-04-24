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
    
    /// The date of the Beacon
    var date: NSDate
    
    init(json: JSON) {
        id = json[API.EventId].intValue
        userID = json[API.UserId].intValue
        title = json[API.EventTitle].stringValue
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = APIDateFormat
        date = formatter.dateFromString(json[API.EventDate].stringValue)!
    }
}
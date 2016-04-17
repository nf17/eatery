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
    var id: Int
    var userID: Int
    var title: String
    var active: Bool
    var creationDate: NSDate
    var updatedDate: NSDate
}
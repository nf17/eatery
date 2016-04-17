//
//  APIManager.swift
//  Eatery
//
//  Created by Daniel Li on 4/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private enum Router: URLStringConvertible {
    
    case Root
    
    static let BaseURLString = "http://localhost"
    var URLString: String {
        let path: String = {
            switch self {
            case .Root:
                return "/"
            }
        }()
        return Router.BaseURLString + path
    }
}

struct API {
    
    /*          Requests            */
    
    // Authentication
    static let SessionCode  = "session_code"
    static let APIKey       = "api_key"
    
    // User
    static let UserId           = "id"
    static let UserFirstName    = "fname"
    static let UserLastName     = "lname"
    static let UserFriendsCount = "friends_count"
    static let UserPopularity   = "popularity"
    static let UserPhone        = "phone"
    
    // BeaconEvent
    static let EventId              = "id"
    static let EventUserId          = "user_id"
    static let EventTitle           = "title"
    static let EventActive          = "active"
    static let EventCreationDate    = "created_at"
    static let EventUpdatedDate     = "updated_at"
    
    /*          Responses           */
    
    // Top Level
    static let Data         = "data"
    static let Success      = "success"
}

private var SessionCode: String!

/**
 The APIManager connects to Eatery's backend endpoints.
 */
class APIManager {
    
    /// Shared singleton of APIManager
    static let sharedInstance: APIManager = APIManager()
    
    /// Private init to prevent public initialization
    private init() {    }
    
    // MARK: - Authentication
    
    private func parametersWithAuth(parameters: [String : AnyObject] = [:]) -> [String : AnyObject] {
        var dict: [String : AnyObject] = [API.SessionCode : SessionCode, API.APIKey : EateryAPIKey]
        for (key, value) in parameters {
            dict[key] = value
        }
        return dict
    }
    
    // MARK: - Sign In
    
    /// Sign in and gives a user object
    func signIn(completion: (NSError?) -> Void) {
        makeRequest(.POST, params: [:], router: .Root) { (data, error) in
            
        }
    }
    
    // MARK: - Beacons...
    
    // MARK: - Request Helper Method
    
    private func makeRequest(method: Alamofire.Method, params: [String: AnyObject], router: Router, completion: (JSON?, NSError?) -> Void) {
        Alamofire.request(method, router, parameters: params)
            .responseJSON { response in
                if let error = response.result.error {
                    completion(nil, error)
                    return
                }
                guard let data = response.data else { return }
                let json = JSON(data: data)
                completion(json, nil)
        }
    }
}
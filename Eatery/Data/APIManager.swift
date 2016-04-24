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
    case SignUp
    case Login
    case Logout
    
    static let BaseURLString = "http://10.148.10.117:3000/api/v1"
    
    var URLString: String {
        let path: String = {
            switch self {
            case .Root:
                return "/"
            case .SignUp:
                return "/users/sign_up"
            case .Login:
                return "/login"
            case .Logout:
                return "/logout"
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
    static let User                 = "user"
    static let UserId               = "id"
    static let UserFirstName        = "fname"
    static let UserLastName         = "lname"
    static let UserPhone            = "phone_number"
    static let UserPassword         = "password"
    static let UserFriendsCount     = "friends_count"
    static let UserPopularity       = "popularity"

    
    // BeaconEvent
    static let EventId              = "id"
    static let EventUserId          = "user_id"
    static let EventTitle           = "title"
    static let EventActive          = "active"
    static let EventCreationDate    = "created_at"
    static let EventUpdatedDate     = "updated_at"
    
    /*          Responses           */
    
    // Common
    static let Data         = "data"
    static let Success      = "success"
    static let Errors       = "errors"
    
    // Login
    static let Session      = "session"
}

private var SessionCode: String? {
    get {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey("SessionCode")
    }
    set {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(newValue, forKey: "SessionCode")
    }
}

/**
 The APIManager connects to Eatery's backend endpoints.
 */
class APIManager {
    
    /// Private init to prevent public initialization
    private init() {    }
    
    // MARK: - Authentication
    
    private static func authParameters(withParameters parameters: [String : AnyObject] = [:]) -> [String : AnyObject] {
        var dict: [String : AnyObject] = [API.APIKey : EateryAPIKey]
        if SessionCode != nil {
            dict[API.Session] = [API.SessionCode : SessionCode!]
        }
        for (key, value) in parameters {
            dict[key] = value
        }
        return dict
    }
    
    // MARK: - User Accounts
    
    /**
     
     Signs up for a new account with the given information.
     
     - parameters:
        - firstName: The user's first name.
        - lastName: The user's last name.
        - phone: The user's phone number formatted correctly TODO: How should this be formatted?
        - password: The user's chosen password.
        - completion: Completion handler for the request. If the user creation was successful, user is the User object created and error is nil. Otherwise, user is nil and error is the error that occurred.
     
     */
    static func signUp(firstName: String, lastName: String, phone: String, password: String, completion: (user: User?, error: NSError?) -> Void) {
        let parameters = [
            API.User : [
                API.UserFirstName : firstName,
                API.UserLastName : lastName,
                API.UserPhone : phone,
                API.UserPassword : password
            ]
        ]
        makeRequest(.POST, params: authParameters(withParameters: parameters), router: .SignUp) { (json, error) in
            var user: User? = nil
            if error == nil {
                user = User(json: json![API.User])
            }
            completion(user: user, error: error)
        }
    }
    
    /**
     
     Attempts to sign in with a given phone number and password
     
     - parameters:
        - phone: The phone number formatted correctly TODO: How should this be formatted?
        - password: The password.
        - completion: Completion handler for the request. If the sign in was successful, error is nil. Otherwise, error is the error that occurred.
     
     - Important:
     This has not been tested.
     
     */
    static func logIn(phone: String, password: String, completion: (error: NSError?) -> Void) {
        let parameters = [
            API.User : [
                API.UserPhone : phone,
                API.UserPassword : password
            ]
        ]
        makeRequest(.POST, params: authParameters(withParameters: parameters), router: .Login) { (json, error) in
            if error == nil {
                SessionCode = json![API.Data][API.SessionCode].stringValue
            }
            completion(error: error)
        }
    }
    
    /**
     
     Attempts to sign out the current user.
     
     - Important:
     This has not been tested.
     
     */
    static func logOut(completion: (error: NSError?) -> Void) {
        makeRequest(.POST, params: authParameters(), router: .Logout) { (json, error) in
            if error != nil {
                SessionCode = nil
            }
            completion(error: error)
        }
    }
    
    
    
    // MARK: - Beacons...
    
    // MARK: - Request Helper Method
    
    private static func makeRequest(method: Alamofire.Method, params: [String: AnyObject], router: Router, completion: (json: JSON?, error: NSError?) -> Void) {
        Alamofire.request(method, router, parameters: params)
            .responseJSON { response in
                if let error = response.result.error {
                    completion(json: nil, error: error)
                    return
                }
                
                let json = JSON(data: response.data!)
                
                print(json)
                
                if !json[API.Success].boolValue {
                    // TODO: Error code, multiple errors
                    let error = NSError(domain: "EateryBackendDomain", code: -99999, userInfo: [kCFErrorLocalizedDescriptionKey : json[API.Data][API.Errors].arrayValue[0].stringValue])
                    completion(json: nil, error: error)
                }
                completion(json: json, error: nil)
        }
    }
}
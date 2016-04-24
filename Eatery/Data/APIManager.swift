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
    case CreateEvent
    case UpdateEvent(Int)
    case DeleteEvent(Int)
    
    static let BaseURLString = "http://10.148.7.14:3000/api/v1"
    
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
            case .CreateEvent:
                return "/events/create"
            case .UpdateEvent(let id):
                return "/events/update/\(id)"
            case .DeleteEvent(let id):
                return "/events/delete/\(id)"
            }
        }()
        return Router.BaseURLString + path
    }
}

struct API {
    
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
    static let Event                = "event"
    static let EventId              = "id"
    static let EventUserId          = "user_id"
    static let EventTitle           = "title"
    static let EventActive          = "active"
    static let EventCreationDate    = "created_at"
    static let EventUpdatedDate     = "updated_at"
    static let EventDate            = "event_time"
    
    // Responses
    static let Data         = "data"
    static let Success      = "success"
    static let Errors       = "errors"
}

let APIDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"

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
            dict[API.SessionCode] = SessionCode
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
        - phone: The user's phone number formatted as a string of numbers.
        - password: The user's chosen password.
        - completion: Completion handler for the request. If the user creation was successful, `user` is the User object created and `error` is `nil`. Otherwise, `user` is `nil` and `error` is the error that occurred.
     
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
     
     Attempts to sign in with a given phone number and password. There must not be a `User` signed in already.
     
     - parameters:
        - phone: The phone number formatted as a string of numbers.
        - password: The password.
        - completion: Completion handler for the request. If the sign in was successful, `error` is `nil`. Otherwise, `error` is the error that occurred.
     
     - Important:
     This has not been tested.
     
     */
    static func logIn(phone: String, password: String, completion: (error: NSError?) -> Void) {
        if SessionCode != nil {
            let error = NSError(domain: "EateryBackendDomain", code: -99999, userInfo: [kCFErrorLocalizedDescriptionKey : "A user is still logged in."])
            completion(error: error)
            return
        }
        let parameters = [
            API.User : [
                API.UserPhone : phone,
                API.UserPassword : password
            ]
        ]
        makeRequest(.POST, params: authParameters(withParameters: parameters), router: .Login) { (json, error) in
            if error == nil {
                SessionCode = json![API.SessionCode].stringValue
            }
            completion(error: error)
        }
    }
    
    /**
     
     Attempts to sign out the current user.
     
     - parameters:
        - completion: Completion handler for the request. If the sign out succeeds, `error` is `nil`. Otherwise, `error` is the error that occurred.
     
     */
    static func logOut(completion: (error: NSError?) -> Void) {
        makeRequest(.POST, params: authParameters(), router: .Logout) { (json, error) in
            if error == nil {
                SessionCode = nil
            }
            completion(error: error)
        }
    }
    
    // MARK: - Events
    
    /**
     
     Creates a new `BeaconEvent` with the given title.
     
     - parameters:
        - title: The title of the `BeaconEvent`.
        - date: The date of the `BeaconEvent`. This must be in the future.
        - completion: Completion handler for the request. If the creation is successful, `event` is the `BeaconEvent` returned, and `error` is `nil`. Otherwise, `event` is `nil` and `error` is the error that occurred.
     
     */
    static func createEvent(title: String, date: NSDate, completion: (event: BeaconEvent?, error: NSError?) -> Void) {
        let parameters = [
            API.Event : [
                API.EventTitle : title,
                API.EventDate : date
            ]
        ]
        makeRequest(.POST, params: authParameters(withParameters: parameters), router: .CreateEvent) { (json, error) in
            var event: BeaconEvent? = nil
            if error == nil {
                event = BeaconEvent(json: json!)
            }
            completion(event: event, error: error)
        }
    }
    
    /**
     
     Updates a `BeaconEvent` with the given info.
     
     - parameters:
        - eventID: The `BeaconEvent`'s `id`, which cannot be `nil`.
        - title: (optional) Title if changed.
        - ownerID: (optional) Owner's `id` if changed.
        - date: (optional) Date of the `BeaconEvent` if changed.
        - completion: Completion handler for the request. If the update succeeds, `updatedEvent` is the newly updated `BeaconEvent` and `error` is `nil`. Otherwise, `error` is the error that occurred and `updatedEvent` is `nil`.
     
     */
    static func updateEvent(eventID: Int, title: String?, ownerID: Int?, date: NSDate?, completion: (updatedEvent: BeaconEvent?, error: NSError?) -> Void) {
        var eventParameters = [String : AnyObject]()
        if let title = title {
            eventParameters[API.EventTitle] = title
        }
        if let ownerID = ownerID {
            eventParameters[API.EventUserId] = ownerID
        }
        if let date = date {
            eventParameters[API.EventDate] = date
        }
        let parameters = [
            API.Event : eventParameters
        ]
        makeRequest(.POST, params: authParameters(withParameters: parameters), router: .UpdateEvent(eventID)) { (json, error) in
            var updatedEvent: BeaconEvent? = nil
            if error == nil {
                updatedEvent = BeaconEvent(json: json!)
            }
            completion(updatedEvent: updatedEvent, error: error)
        }
    }
    
    /**
     
     Deletes a `BeaconEvent` with the given `id`.
     
     - parameters:
        - id: The `id` of the `BeaconEvent` to be deleted.
        - completion: Completion handler for the request. If the deletion succeeds, `error` is `nil`. Otherwise, `error` is the error that occurred.
     
     */
    static func deleteEvent(id: Int, completion: (error: NSError?) -> Void) {
        makeRequest(.POST, params: authParameters(), router: .DeleteEvent(id)) { (json, error) in
            completion(error: error)
        }
    }
    
    // MARK: - Event Requests
    
    /**
     
     Creates a `BeaconRequest` with the `BeaconEvent` `id` and the `id` of the `User` being invited.
     
     - parameters:
     - eventID: The `id` of the `BeaconEvent`.
     - userID: The `id` of the `User` being invited.
     - completion: Completion handler for the request. If the request succeeds, `request` is the request that was created, and `error` is `nil`. Otherwise, `error` is the error that occurred and `request`.
     */
    static func createBeaconRequest(eventID: Int, userID: Int, completion: (error: NSError?) -> Void) {
        
    }
    
    
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
                    let error = NSError(domain: "EateryBackendDomain", code: -99999, userInfo: [kCFErrorLocalizedDescriptionKey : json[API.Data][API.Errors].arrayValue.first?.string ?? "Unknown Error"])
                    completion(json: nil, error: error)
                    return
                }
                completion(json: json[API.Data], error: nil)
        }
    }
}
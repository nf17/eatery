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
    static let BaseURLString = "http://localhost"
    
    case Root
    
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

class APIManager {
    
    /// Shared singleton of APIManager
    static let sharedInstance: APIManager = APIManager()
    
    /// Private init to prevent public initialization
    private init() {}
    
    
    
    // MARK: - Request Methods
    
    private func request<O, T>(method: Alamofire.Method, params: [String: AnyObject], router: Router, map: O -> T?, completion: (T -> Void)?) {
        Alamofire.request(method, router, parameters: params)
            .responseJSON { response in
                if let error = response.result.error {
                    print(error) // temp
                }
                if let json = response.result.value as? O {
                    if let object = map(json) {
                        completion?(object)
                    }
                }
        }
    }
}
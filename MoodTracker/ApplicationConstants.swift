//
//  ApplicationConstants.swift
//  MoodTracker
//
//  Created by axiom88 06/10/2016.
//  Copyright © 2016 Axiom. All rights reserved.
//

import Foundation

struct ApplicationConstants {
    
    // Graph information
    static let clientId = "ENTER_CLIENT_ID"
    static let scopes   = ["User.ReadBasic.All",
                           "offline_access"]
    
    // Cognitive services information
    static let ocpApimSubscriptionKey = "b1c3f8939e7043a585ff3b86964c0312"
}

enum Error: Swift.Error {
    case unexpectedError(nsError: NSError?)
    case serviceError(json: [String: AnyObject])
    case jSonSerializationError
}

//typealias JSON = AnyObject
typealias JSONDictionary = [String: AnyObject]
typealias JSONArray = [AnyObject]

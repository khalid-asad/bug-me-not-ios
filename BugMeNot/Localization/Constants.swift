//
//  Constants.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation

enum Constants: String {
    case queryRequestBaseURL
    case queryRequestPath
    
    var rawValue: String {
        switch self {
        case .queryRequestBaseURL:
            return "http://bugmenot.com"
        case .queryRequestPath:
            return "/view/%@"
        }
    }
}

enum FormattedConstants {
    case queryRequestPath(query: String)
    
    var rawValue: String {
        switch self {
        case .queryRequestPath(let query):
            return String(format: Constants.queryRequestPath.rawValue, query)
        }
    }
}

//
//  Constants.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation

enum Constants: String {
    case copyToastMessage
    case queryRequestBaseURL
    case queryRequestPath
    case searchPlaceholder
    case title
    case unknown
    
    var rawValue: String {
        switch self {
        case .copyToastMessage:
            return "%@ copied to clipboard!"
        case .queryRequestBaseURL:
            return "http://bugmenot.com"
        case .queryRequestPath:
            return "/view/%@"
        case .searchPlaceholder:
            return "Search Website (i.e. theathletic.com)"
        case .title:
            return "BugMeNot"
        case .unknown:
            return "?"
        }
    }
}

enum FormattedConstants {
    case copyToastMessage(field: String)
    case queryRequestPath(query: String)
    
    var rawValue: String {
        switch self {
        case .copyToastMessage(let field):
            return String(format: Constants.copyToastMessage.rawValue, field)
        case .queryRequestPath(let query):
            return String(format: Constants.queryRequestPath.rawValue, query)
        }
    }
}

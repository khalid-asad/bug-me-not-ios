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
    case searchBannedInputMessage
    case searchEmptyMessage
    case searchInvalidInputMessage
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
        case .searchBannedInputMessage:
            return "This site has been barred from the bugmenot system.\n\nSites should only appear blocked here if they match one or more of the following criteria:\n- Pay-per-view: users pay money to access the site\n- Community: users register only to add/change content (but not to view)\n- Fraud risk: user accounts contain sensitive details e.g. banks, online stores, etc"
        case .searchEmptyMessage:
            return "Try entering in a url in the search bar above."
        case .searchInvalidInputMessage:
            return "Invalid domain entered (expecting 'example.com'). Please try again with a valid URL."
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

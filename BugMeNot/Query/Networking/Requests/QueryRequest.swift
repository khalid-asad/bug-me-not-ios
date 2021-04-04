//
//  QueryRequest.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation
import protocol PlatformCommon.Networkable

struct QueryRequest: Networkable {

    var query: String
        
    var baseURL: String {
        Constants.queryRequestBaseURL.rawValue
    }
    
    var urlPath: String? {
        FormattedConstants.queryRequestPath(query: query).rawValue
    }
}

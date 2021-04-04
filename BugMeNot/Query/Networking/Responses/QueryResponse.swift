//
//  QueryResponse.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation
import SwiftSoup

struct QueryResponse {
    var username: String?
    var password: String?
    var successRate: String?
    var votes: String?
    var age: String?
}

// MARK: - Internal Methods
extension QueryResponse {
    
    static func response(from document: Document) -> [QueryResponse] {
        return []
    }
}

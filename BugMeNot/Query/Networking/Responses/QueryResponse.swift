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
        let body = document.body()
        do {
            let content = try body?.getElementById("content")
            let contentArray = content?.children()
            let accountsContent = contentArray?.filter({ $0.hasClass("account") })
            guard let accountContent = accountsContent, !accountContent.isEmpty else { return [] }
            
            return try accountContent.compactMap {
                let string = try $0.text()
                let stringArray = string.split(separator: " ")
                var response = QueryResponse()
                
                if stringArray.first == "Username:", let username = stringArray[safe: 1] {
                    response.username = String(username)
                }
                
                if stringArray[safe: 2] == "Password:", let password = stringArray[safe: 3] {
                    response.password = String(password)
                }
                
                if stringArray[safe: 4] == "Stats:" {
                    if let successInt = stringArray[safe: 5], let successString = stringArray[safe: 6], let rateString = stringArray[safe: 7] {
                        response.successRate = "\(String(successInt)) \(String(successString)) \(String(rateString))"
                    }
                    if let votesInt = stringArray[safe: 8], let votesString = stringArray[safe: 9] {
                        response.votes = "\(String(votesInt)) \(String(votesString))"
                    }
                    if let ageInt = stringArray[safe: 10], let monthsString = stringArray[safe: 11], let oldString = stringArray[safe: 12] {
                        response.age = "\(String(ageInt)) \(String(monthsString)) \(String(oldString))"
                    }
                }
                
                return response
            }
        } catch {
            return []
        }
    }
}

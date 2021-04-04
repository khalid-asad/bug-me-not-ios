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
    
    enum CodingKeys: String {
        case content
        case account
    }
    
    enum SubStringCodingKeys: String.SubSequence {
        case username = "Username:"
        case password = "Password:"
        case other = "Other:"
        case stats = "Stats:"
    }
}

extension QueryResponse {
    
    var formattedUsername: NSAttributedString {
        NSMutableAttributedString(string: "Username: \(username ?? "")").boldedString("Username:", boldFont: ThemeManager.boldTitleFont)
    }
    
    var formattedPassword: NSAttributedString {
        NSMutableAttributedString(string: "Password: \(password ?? "")").boldedString("Password:", boldFont: ThemeManager.boldTitleFont)
    }
    
    var formattedSuccessRate: String? {
        let successRateStrings = successRate?.split(separator: " ")
        guard let successRateString = successRateStrings?.first else {
            return Constants.unknown.rawValue
        }
        return String(successRateString)
    }
    
    var formattedVotes: String? {
        let voteStrings = votes?.split(separator: " ")
        guard let voteCountString = voteStrings?.first, let voteCount = Int(voteCountString) else {
            return Constants.unknown.rawValue
        }
        return String(voteCount)
    }
    
    var formattedAge: String {
        let ageStrings = age?.split(separator: " ")
        guard let ageString = ageStrings?.first,
            let age = Int(ageString),
            let timePeriod = ageStrings?[safe: 1]
        else {
            return Constants.unknown.rawValue
        }
        return String(age) + timePeriod.prefix(1)
    }
}

// MARK: - Internal Methods
extension QueryResponse {
    
    static func response(from document: Document) -> [QueryResponse] {
        let body = document.body()
        do {
            let content = try body?.getElementById(CodingKeys.content.rawValue)
            let contentArray = content?.children()
            let accountsContent = contentArray?.filter({ $0.hasClass(CodingKeys.account.rawValue) })
            guard let accountContent = accountsContent, !accountContent.isEmpty else { return [] }
            
            return try accountContent.compactMap {
                let string = try $0.text()
                let stringArray = string.split(separator: " ")
                var response = QueryResponse()
                
                var index = 0
                
                if stringArray.first == SubStringCodingKeys.username.rawValue, let username = stringArray[safe: index + 1] {
                    response.username = String(username)
                }
                
                index += 2
                
                if stringArray[safe: index] == SubStringCodingKeys.password.rawValue {
                    if let password = stringArray[safe: index + 1],
                        password != SubStringCodingKeys.other.rawValue,
                        password != SubStringCodingKeys.stats.rawValue {
                        response.password = String(password)
                        index += 2
                    } else {
                        index += 1
                    }
                }
                                
                if stringArray[safe: index] == SubStringCodingKeys.other.rawValue {
                    index += 2 // Ignore and move on to the next set
                }
                
                if stringArray[safe: index] == SubStringCodingKeys.stats.rawValue {
                    index += 1
                    if let successInt = stringArray[safe: index], let successString = stringArray[safe: index + 1], let rateString = stringArray[safe: index + 2] {
                        response.successRate = "\(String(successInt)) \(String(successString)) \(String(rateString))"
                    }
                    index += 3
                    if let votesInt = stringArray[safe: index], let votesString = stringArray[safe: index + 1] {
                        response.votes = "\(String(votesInt)) \(String(votesString))"
                    }
                    index += 2
                    if let ageInt = stringArray[safe: index], let monthsString = stringArray[safe: index + 1], let oldString = stringArray[safe: index + 2] {
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

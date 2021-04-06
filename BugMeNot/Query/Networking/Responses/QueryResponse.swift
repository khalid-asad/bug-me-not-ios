//
//  QueryResponse.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation
import SwiftSoup
import enum PlatformCommon.NetworkError

struct QueryResponse {
    var username: String?
    var password: String?
    var successRate: String?
    var votes: String?
    var age: String?
    var originalSequence: Int
    
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

// MARK: - Integer Values for Sorting
extension QueryResponse {
    
    var successRateInteger: Int {
        let successRateInt = successRate?
            .split(separator: " ")
            .first?
            .replacingOccurrences(of: "%", with: "")
        return Int(String(successRateInt ?? "0")) ?? 0
    }
    
    var votesInteger: Int {
        let votesInt = votes?
            .split(separator: " ")
            .first
        return Int(String(votesInt ?? "0")) ?? 0
    }

    var ageDate: Date {
        let ageStrings = age?.split(separator: " ")
        guard let ageString = ageStrings?.first,
            let age = Int(ageString),
            let timePeriod = ageStrings?[safe: 1]
        else {
            return Date()
        }
        var timeType: Calendar.Component {
            let time = timePeriod.prefix(1)
            switch time {
            case "y": return .year
            case "m": return .month
            case "d": return .day
            default: return .minute
            }
        }
        return Date().addToDate(value: -age, type: timeType)
    }
}

// MARK: - Formatted String Values
extension QueryResponse {
    
    var formattedUsername: NSMutableAttributedString {
        NSMutableAttributedString(string: "\(SubStringCodingKeys.username.rawValue) \(username ?? "")")
            .boldedString("\(SubStringCodingKeys.username.rawValue)", boldFont: ThemeManager.boldTitleFont)
    }
    
    var formattedPassword: NSMutableAttributedString {
        NSMutableAttributedString(string: "\(SubStringCodingKeys.password.rawValue) \(password ?? "")")
            .boldedString("\(SubStringCodingKeys.password.rawValue)", boldFont: ThemeManager.boldTitleFont)
    }
    
    var formattedSuccessRate: String {
        String(successRateInteger) + "%"
    }
    
    var formattedVotes: String {
        String(votesInteger)
    }
    
    var formattedAge: String {
        ageDate.toMonthYear
    }
}

// MARK: - Internal Methods
extension QueryResponse {
    
    static func response(from document: Document) throws -> [QueryResponse] {
        let body = document.body()
        let content = try body?.getElementById(CodingKeys.content.rawValue)
        let contentArray = content?.children()
        let accountsContent = contentArray?.filter({ $0.hasClass(CodingKeys.account.rawValue) })
        guard let accountContent = accountsContent, !accountContent.isEmpty else { throw NetworkError.emptyResponse }
        
        return try accountContent.enumerated().compactMap { (index, item) in
            let string = try item.text()
            let stringArray = string.split(separator: " ")
            var response = QueryResponse(originalSequence: index)
            
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
    }
}

//
//  NetworkRequestProtocol.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation
import enum PlatformCommon.NetworkError

protocol NetworkRequestProtocol {
    
    /// Fetches a query to BugMeNot.com with a search term.
    /// - parameter term: A search term in the format of a String (hopefully percent encoded).
    func fetchQuery(_ term: String, completion: @escaping (Result<[QueryResponse], NetworkError>) -> Void)
}

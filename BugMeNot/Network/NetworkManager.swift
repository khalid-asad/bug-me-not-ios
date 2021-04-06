//
//  NetworkManager.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation
import SwiftSoup
import enum PlatformCommon.NetworkError

final class NetworkManager: NetworkRequestProtocol {
    
    static let shared = NetworkManager(session: NetworkSession())
    
    var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func fetchQuery(_ term: String, completion: @escaping (Result<[QueryResponse], NetworkError>) -> Void) {
        QueryRequest(query: term).fetchRawData() { result in
            switch result {
            case .success(let data):
                let htmlString = String(decoding: data, as: UTF8.self)
                do {
                    let document: Document = try SwiftSoup.parse(htmlString)
                    let response = try QueryResponse.response(from: document)
                    completion(.success(response))
                } catch(let error) {
                    completion(.failure(error as? NetworkError ?? .unableToDecodeJSON))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

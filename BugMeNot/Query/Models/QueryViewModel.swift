//
//  QueryViewModel.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation
import PlatformCommon

final class QueryViewModel {
    var items: [QueryResponse]!
    var cache: NSCache<AnyObject, AnyObject>!
}

// MARK: - Internal Methods
extension QueryViewModel {
    
    func fetch(query: String, completion: @escaping ((NetworkError?) -> Void)) {
        NetworkManager.shared.fetchQuery(query) { [weak self] result in
            guard let self = self else { return completion(.noReference) }
            self.items = []
            switch result {
            case .success(let queryResponse):
                self.items = queryResponse
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}

//
//  NetworkService+Context.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation
import Combine

protocol NetworkServiceContext {
    func getnewsPublisher(query: String, page: Int, sortedBy: TextNewsNetworkModel.SortType, size: Int) -> AnyPublisher<TextNewsNetworkModel, NetworkServiceError>
}

extension NetworkService: NetworkServiceContext {
    func getnewsPublisher(query: String, page: Int, sortedBy: TextNewsNetworkModel.SortType, size: Int) -> AnyPublisher<TextNewsNetworkModel, NetworkServiceError> {
//        let headers = [
//            "X-Api-Key": Keys.newsKey.rawValue
//        ]
        let queryItems: [String: LosslessStringConvertible] = [
            "q": "\(query)",
            "apiKey": Keys.newsKey.rawValue,
            "language": "en",
            "sortBy": sortedBy.rawValue,
            "pageSize": size,
            "page": page
        ]
        
        let router = Router(host: "newsapi.org",
                            path: "/v2/everything",
                            queryItems: queryItems,
                            headers: [:])
        
        return publisher(route: router)
    }
}

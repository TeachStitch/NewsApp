//
//  TextNewsNetworkModel.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

struct TextNewsNetworkModel: Decodable {
    let totalResults: Int
    let articles: [Article]
    
    struct Article: Decodable {
        let title: String?
        let description: String?
        let author: String?
        let urlString: String
        let imageUrlString: String?
        let source: Source?
        
        enum CodingKeys: String, CodingKey {
            case title
            case description
            case urlString = "url"
            case imageUrlString = "urlToImage"
            case source
            case author
        }
        
        struct Source: Decodable {
            let name: String
        }
    }
    
    enum SortType: String {
        case publishedAt
        case relevancy
        case popularity
    }
}

//
//  NewsModel.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation
import Combine

protocol NewsModelProvider {
    func getTextNewsPublisher(query: String) -> AnyPublisher<TextNews, NetworkServiceError>
    func getPaginatedPublisher(page: Int) -> AnyPublisher<TextNews, NetworkServiceError>
    func addToFavourites(article: TextNews.Article) -> AnyPublisher<ArticleDTO, Error>
}

class NewsModel: NewsModelProvider {
    
    private enum Constants {
        static let pageSize = 20
    }
    
    private let networkService: NetworkServiceContext
    private let persistenceService: PersistenceServiceContext
    private var lastQuery: String?
    
    init(networkService: NetworkServiceContext = NetworkService.shared, persistenceService: PersistenceServiceContext = PersistenceService.shared) {
        self.networkService = networkService
        self.persistenceService = persistenceService
    }
    
    func getTextNewsPublisher(query: String) -> AnyPublisher<TextNews, NetworkServiceError> {
        let handledQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        lastQuery = handledQuery
        
        return networkService.getnewsPublisher(query: handledQuery, page: 1, sortedBy: .publishedAt, size: Constants.pageSize)
            .map { TextNews(model: $0) }
            .eraseToAnyPublisher()
    }
    
    func getPaginatedPublisher(page: Int) -> AnyPublisher<TextNews, NetworkServiceError> {
        guard let lastQuery else { return Fail(error: NetworkServiceError.general("There is no query")).eraseToAnyPublisher() }
        
        return networkService.getnewsPublisher(query: lastQuery, page: page, sortedBy: .publishedAt, size: Constants.pageSize)
            .map { TextNews(model: $0) }
            .eraseToAnyPublisher()
    }
    
    func addToFavourites(article: TextNews.Article) -> AnyPublisher<ArticleDTO, Error> {
        persistenceService.create(article: ArticleDTO(model: article)).eraseToAnyPublisher()
    }
}

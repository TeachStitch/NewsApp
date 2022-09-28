//
//  FavouriteArticlesModel.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation
import Combine

protocol FavouriteArticlesModelProvider {
    func getFavouriteArticlesPublisher() -> AnyPublisher<[ArticleDTO], Error>
    func deleteArticle(_ article: ArticleDTO) -> AnyPublisher<ArticleDTO, Error>
}

class FavouriteArticlesModel: FavouriteArticlesModelProvider {
    private let persistenceService: PersistenceServiceContext
    
    init(persistenceService: PersistenceServiceContext = PersistenceService.shared) {
        self.persistenceService = persistenceService
    }
    
    func getFavouriteArticlesPublisher() -> AnyPublisher<[ArticleDTO], Error> {
        persistenceService.fetchArticles().eraseToAnyPublisher()
    }
    
    func deleteArticle(_ article: ArticleDTO) -> AnyPublisher<ArticleDTO, Error> {
        persistenceService.deleteArticle(article).eraseToAnyPublisher()
    }
}

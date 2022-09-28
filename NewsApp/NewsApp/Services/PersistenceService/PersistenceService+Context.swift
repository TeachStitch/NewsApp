//
//  PersistenceService+Context.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Combine

protocol PersistenceServiceContext {
    func create(article: ArticleDTO) -> AnyPublisher<ArticleDTO, Error>
    func fetchArticles() -> AnyPublisher<[ArticleDTO], Error>
    func deleteArticle(_ article: ArticleDTO) -> AnyPublisher<ArticleDTO, Error>
}

extension PersistenceService: PersistenceServiceContext {
    func create(article: ArticleDTO) -> AnyPublisher<ArticleDTO, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    try await self.backgroundContext.perform { [weak self] in
                        guard let self = self else { return }
                        
                        let entity = ArticleEntity(article: article, insertInto: self.backgroundContext)
                        guard let article = ArticleDTO(entity) else { throw PersistenceServiceError.general("Creation Errpr") }
                        promise(.success(article))
                    }
                    
                    try await self.saveContextIfNeeded(self.backgroundContext)
                } catch let error {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchArticles() -> AnyPublisher<[ArticleDTO], Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let entities: [ArticleEntity] = try await self.fetch(on: self.mainContext)
                    let articles = entities.compactMap { ArticleDTO($0) }
                    promise(.success(articles))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteArticle(_ article: ArticleDTO) -> AnyPublisher<ArticleDTO, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    guard let url = article.url else { throw PersistenceServiceError.general("Url is nil") }
                    try await self.delete(url: url, on: self.backgroundContext)
                    try await self.saveContextIfNeeded(self.backgroundContext)
                    promise(.success(article))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

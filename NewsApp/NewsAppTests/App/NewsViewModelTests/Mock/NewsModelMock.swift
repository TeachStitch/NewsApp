//
//  NewsModelMock.swift
//  NewsAppTests
//
//  Created by Arsenii Kovalenko on 29.09.2022.
//

import Foundation
import Combine
@testable import NewsApp

class NewsModelMock: NewsModelProvider {

    var networkState: State = .available
    var addToFavouritesState: State = .available
    var textNews: TextNews?
    var query: String?

    enum State {
        case available
        case unavailable(NetworkServiceError)
    }

    func getTextNewsPublisher(query: String) -> AnyPublisher<TextNews, NetworkServiceError> {
        self.query = query
        
        switch networkState {
        case .available:
            return Just(TextNews.mock)
            .setFailureType(to: NetworkServiceError.self)
            .eraseToAnyPublisher()
        case .unavailable(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func getPaginatedPublisher(page: Int) -> AnyPublisher<TextNews, NetworkServiceError> {
        switch networkState {
        case .available:
            return Just(TextNews.mock)
            .setFailureType(to: NetworkServiceError.self)
            .eraseToAnyPublisher()
        case .unavailable(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func addToFavourites(article: NewsApp.TextNews.Article) -> AnyPublisher<ArticleDTO, Error> {
        switch addToFavouritesState {
        case .available:
            return Just(ArticleDTO.mock)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .unavailable(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

//
//  FavouriteArticlesViewModel.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Combine
import Foundation

protocol FavouriteArticlesViewModelProvider {
    var title: String { get }
    
    func transform(_ input: AnyPublisher<FavouriteArticlesViewModelInput, Never>) -> AnyPublisher<FavouriteArticlesViewModelOutput, Never>
}

enum FavouriteArticlesViewModelInput {
    case onLoad
    case newsTapped(ArticleDTO)
    case swipedToDeleteArticle(ArticleDTO)
}

enum FavouriteArticlesViewModelOutput {
    case showAlert(title: String, message: String)
    case showArticle(URL)
    case deleteArticle(ArticleDTO)
    case updateArticles(_ articles: [ArticleDTO])
}

class FavouriteArticlesViewModel: FavouriteArticlesViewModelProvider {
    // MARK: - Properties
    let title = "NEWS"
    private let model: FavouriteArticlesModelProvider
    private let output = PassthroughSubject<FavouriteArticlesViewModelOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(model: FavouriteArticlesModelProvider) {
        self.model = model
    }
    
    // MARK: - Method(s)
    func transform(_ input: AnyPublisher<FavouriteArticlesViewModelInput, Never>) -> AnyPublisher<FavouriteArticlesViewModelOutput, Never> {
        input.sink { [weak self] event in
            switch event {
            case .onLoad:
                self?.fetchFavouriteArticles()
            case .newsTapped(let article):
                self?.output.send(.showArticle(article.articleUrl))
            case .swipedToDeleteArticle(let article):
                self?.deleteArticle(article)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func fetchFavouriteArticles() {
        model.getFavouriteArticlesPublisher()
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.output.send(.showAlert(title: "Error", message: error.localizedDescription))
            } receiveValue: { [weak self] articles in
                self?.output.send(.updateArticles(articles))
            }
            .store(in: &cancellables)
    }
    
    private func deleteArticle(_ article: ArticleDTO) {
        model.deleteArticle(article)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.output.send(.showAlert(title: "Error", message: error.localizedDescription))
            } receiveValue: { [weak self] article in
                self?.output.send(.deleteArticle(article))
            }
            .store(in: &cancellables)
    }
}

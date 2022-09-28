//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation
import Combine

protocol NewsViewModelProvider {
    var title: String { get }
    
    func transform(_ input: AnyPublisher<NewsViewModelInput, Never>) -> AnyPublisher<NewsViewModelOutput, Never>
}

enum NewsViewModelInput {
    case onLoad
    case searchTapped(String)
    case favouritesTapped
    case filterTapped(FilterKind)
    case newsTapped(TextNews.Article)
    case shouldPaginate
    case addToFavouritesTapped(TextNewsTableViewCellViewModelProvider)
}

enum NewsViewModelOutput {
    case showAlert(title: String, message: String)
    case updateNews(_ news: TextNews, appending: Bool)
    case showArticle(URL)
    case showFavouriteArticles
}

class NewsViewModel: NewsViewModelProvider {
    
    private enum Constants {
        static let maxPage = 5
    }
    
    // MARK: - Properties
    let title = "NEWS"
    private let model: NewsModelProvider
    private let output = PassthroughSubject<NewsViewModelOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    
    // MARK: - Initialization
    init(model: NewsModelProvider) {
        self.model = model
    }
    
    // MARK: - Method(s)
    func transform(_ input: AnyPublisher<NewsViewModelInput, Never>) -> AnyPublisher<NewsViewModelOutput, Never> {
        input.sink { [weak self] event in
            switch event {
            case .onLoad:
                break
            case .searchTapped(let text):
                self?.makeQuery(query: text)
            case .favouritesTapped:
                self?.output.send(.showFavouriteArticles)
            case .filterTapped(let kind):
                print(kind)
            case .shouldPaginate:
                self?.paginateQuery()
            case .newsTapped(let article):
                self?.output.send(.showArticle(article.url))
            case .addToFavouritesTapped(let article):
                guard let article = article as? TextNews.Article else { return }
                self?.addToFavourites(article: article)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func makeQuery(query: String) {
        model.getTextNewsPublisher(query: query).sink { [weak self] completion in
            guard case .failure(let error) = completion else { return }
            self?.output.send(.showAlert(title: "Error", message: error.localizedDescription))
        } receiveValue: { [weak self] textNews in
            self?.output.send(.updateNews(textNews, appending: false))
        }
        .store(in: &cancellables)
    }
    
    private func paginateQuery() {
        guard currentPage != Constants.maxPage else { return }
        currentPage += 1
        
        model.getPaginatedPublisher(page: currentPage).sink { [weak self] completion in
            guard case .failure(let error) = completion else { return }
            self?.output.send(.showAlert(title: "Error", message: error.localizedDescription))
        } receiveValue: { [weak self] textNews in
            self?.output.send(.updateNews(textNews, appending: true))
        }
        .store(in: &cancellables)
    }
    
    private func addToFavourites(article: TextNews.Article) {
        model.addToFavourites(article: article)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.output.send(.showAlert(title: "Error", message: error.localizedDescription))
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

enum FilterKind {
    case byCategory
    case byCountry
    case bySources
}

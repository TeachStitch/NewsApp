//
//  ArticleShowViewModel.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation
import Combine

protocol ArticleShowViewModelProvider {
    func transform(_ input: AnyPublisher<ArticleShowViewModelInput, Never>) -> AnyPublisher<ArticleShowViewModelOutput, Never>
}

enum ArticleShowViewModelInput {
    case onLoad
    case backTapped
    case reloadTapped
}

enum ArticleShowViewModelOutput {
    case showAlert(title: String, message: String)
    case loadPage(URL)
    case reloadPage
    case navigateBack
}

class ArticleShowViewModel: ArticleShowViewModelProvider {
    
    // MARK: - Properties
    private let model: ArticleShowModelProvider
    private let output = PassthroughSubject<ArticleShowViewModelOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(model: ArticleShowModelProvider) {
        self.model = model
    }
    
    // MARK: - Method(s)
    func transform(_ input: AnyPublisher<ArticleShowViewModelInput, Never>) -> AnyPublisher<ArticleShowViewModelOutput, Never> {
        input.sink { [weak self] event in
            switch event {
            case .onLoad:
                guard let url = self?.model.articleUrl else { return }
                self?.output.send(.loadPage(url))
            case .backTapped:
                self?.output.send(.navigateBack)
            case .reloadTapped:
                self?.output.send(.reloadPage)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

//
//  ViewControllerAssembler.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

enum ViewControllerAssembler {
    static func getNewsViewController(
        networkService: NetworkServiceContext = NetworkService.shared,
        persistenceService: PersistenceServiceContext = PersistenceService.shared) -> NewsViewController {
            let model = NewsModel(networkService: networkService, persistenceService: persistenceService)
            let viewModel = NewsViewModel(model: model)
            
        return NewsViewController(viewModel: viewModel)
    }
    
    static func getArticleShowViewController(url: URL) -> ArticleShowViewController {
        let model = ArticleShowModel(articleUrl: url)
        let viewModel = ArticleShowViewModel(model: model)
        
        return ArticleShowViewController(viewModel: viewModel)
    }
    
    static func getFavouriteArticlesViewController(persistenceService: PersistenceServiceContext = PersistenceService.shared) -> FavouriteArticlesViewController {
        let model = FavouriteArticlesModel(persistenceService: persistenceService)
        let viewModel = FavouriteArticlesViewModel(model: model)
        
        return FavouriteArticlesViewController(viewModel: viewModel)
    }
}

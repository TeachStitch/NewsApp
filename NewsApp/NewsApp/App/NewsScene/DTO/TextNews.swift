//
//  TextNews.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

struct TextNews {
    let totalResults: Int
    let articles: [Article]
    
    struct Article: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let author: String
        let url: URL
        let imageUrl: URL
        let source: String
    }
}

extension TextNews: Equatable { }

extension TextNews.Article {
    init?(model: TextNewsNetworkModel.Article) {
        guard
            let title = model.title,
            let description = model.description,
            let author = model.author,
            let url = URL(string: model.urlString),
            let imageString = model.imageUrlString,
            let imageUrl = URL(string: imageString),
            imageUrl.scheme == "https",
            let source = model.source?.name
        else { return nil }
        
        self.title = title
        self.description = description
        self.author = author
        self.url = url
        self.imageUrl = imageUrl
        self.source = source
    }
}

extension TextNews {
    init(model: TextNewsNetworkModel) {
        self.totalResults = model.totalResults
        self.articles = model.articles.compactMap { TextNews.Article(model: $0) }
    }
}

extension TextNews.Article: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Cell ViewModels Conformance

extension TextNews.Article: TextNewsTableViewCellViewModelProvider {
}

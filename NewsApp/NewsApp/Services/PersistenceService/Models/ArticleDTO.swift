//
//  ArticleDTO.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import CoreData

struct ArticleDTO {
    let url: URL?
    let title: String
    let articleDescription: String
    let author: String
    let articleUrl: URL
    let source: String
    let imageUrl: URL
}

// MARK: - Initialization
extension ArticleDTO {
    init?(_ entity: ArticleEntity) {
        guard
            let title = entity.title,
            let articleDescription = entity.articleDescription,
            let author = entity.author,
            let articleUrl = entity.articleUrl,
            let source = entity.source,
            let imageUrl = entity.imageUrl
        else { return nil }
        
        self.url = entity.objectID.uriRepresentation()
        self.title = title
        self.articleDescription = articleDescription
        self.author = author
        self.articleUrl = articleUrl
        self.source = source
        self.imageUrl = imageUrl
    }
    
    init(model: TextNews.Article) {
        self.url = nil
        title = model.title
        articleDescription = model.description
        author = model.author
        articleUrl = model.url
        source = model.source
        imageUrl = model.imageUrl
    }
}

extension ArticleDTO: Hashable { }
extension ArticleDTO: BaseTextNewsTableViewCellViewModelProvider {
    var description: String { articleDescription }
}

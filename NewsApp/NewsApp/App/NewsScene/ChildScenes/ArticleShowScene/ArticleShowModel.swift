//
//  ArticleShowModel.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

protocol ArticleShowModelProvider {
    var articleUrl: URL { get }
}

class ArticleShowModel: ArticleShowModelProvider {
    
    let articleUrl: URL
    
    init(articleUrl: URL) {
        self.articleUrl = articleUrl
    }
}

//
//  ArticleEntity+CoreDataClass.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//
//

import Foundation
import CoreData


public class ArticleEntity: NSManagedObject {
    @discardableResult
    convenience init(article: ArticleDTO, insertInto context: NSManagedObjectContext) {
        self.init(entity: ArticleEntity.entity(), insertInto: context)
        self.title = article.title
        self.source = article.source
        self.articleDescription = article.articleDescription
        self.articleUrl = article.articleUrl
        self.imageUrl = article.imageUrl
        self.author = article.author
    }
}

//
//  ArticleEntity+CoreDataProperties.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//
//

import Foundation
import CoreData


extension ArticleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleEntity> {
        return NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var articleDescription: String?
    @NSManaged public var author: String?
    @NSManaged public var articleUrl: URL?
    @NSManaged public var source: String?
    @NSManaged public var imageUrl: URL?

}

extension ArticleEntity : Identifiable {

}

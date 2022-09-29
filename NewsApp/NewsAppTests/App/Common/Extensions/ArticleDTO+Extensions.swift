//
//  ArticleDTO+Extensions.swift
//  NewsAppTests
//
//  Created by Arsenii Kovalenko on 29.09.2022.
//

import Foundation
@testable import NewsApp

extension ArticleDTO {
    static let mock = ArticleDTO(url: nil,
                                 title: "Stamford firefighter sustains minor injury in early morning house fire",
                                 articleDescription: "Firefighters from the West Side Fire Station arrived in less than a minute to find fire spread across three floors of the multifamily home.",
                                 author: "Pat Tomlinson",
                                 articleUrl: URL(string: "https://www.stamfordadvocate.com/news/article/Stamford-firefighter-minor-injury-Fairfield-Ave-17475541.php")!,
                                 source: "Stamfordadvocate.com",
                                 imageUrl: URL(string: "https://s.hdnux.com/photos/01/27/54/14/22987571/5/rawImage.jpg")!)
}

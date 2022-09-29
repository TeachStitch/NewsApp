//
//  TextNews+Extensions.swift
//  NewsAppTests
//
//  Created by Arsenii Kovalenko on 29.09.2022.
//

import Foundation
@testable import NewsApp

extension TextNews {
    static let mock = TextNews(totalResults: 2, articles: [
        Article(title: "Stamford firefighter sustains minor injury in early morning house fire",
                description: "Firefighters from the West Side Fire Station arrived in less than a minute to find fire spread across three floors of the multifamily home.",
                author: "Pat Tomlinson",
                url: URL(string: "https://www.stamfordadvocate.com/news/article/Stamford-firefighter-minor-injury-Fairfield-Ave-17475541.php")!,
                imageUrl: URL(string: "https://s.hdnux.com/photos/01/27/54/14/22987571/5/rawImage.jpg")!,
                source: "Stamfordadvocate.com")
    ])
}

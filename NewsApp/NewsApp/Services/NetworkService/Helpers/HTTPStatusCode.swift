//
//  HTTPStatusCode.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

enum HTTPStatusCode: Int {
    case success = 200
    case created = 201
    case internalServerError = 500
    case pageLimit = 426
    case unauthourized = 401
    case requestLimit = 429
}

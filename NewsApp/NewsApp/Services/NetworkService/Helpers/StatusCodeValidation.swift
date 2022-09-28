//
//  StatusCodeValidation.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

enum StatusCodeValidation {
    case success
    case failure(reason: String)
    case internalServerError
    case unknown
    
    static func handleStatusCode(_ code: Int) -> Self {
        switch HTTPStatusCode(rawValue: code) {
        case .success, .created:
            return .success
        case .internalServerError:
            return .internalServerError
        case .pageLimit:
            return .failure(reason: "Page limit")
        case .requestLimit:
            return .failure(reason: "Request limit")
        case .unauthourized:
            return .failure(reason: "Api Key isn't provided")
        default:
            return .unknown
        }
    }
}

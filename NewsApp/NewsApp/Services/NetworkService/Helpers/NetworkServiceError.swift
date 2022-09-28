//
//  NetworkServiceError.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

enum NetworkServiceError: Error {
    case undefined
    case internalServerError
    case invalidRequest
    case failedDecodingResponse(_ reason: String)
    case general(_ message: String)
}

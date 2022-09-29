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

extension NetworkServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .undefined, .internalServerError:
            return "The operation couldn’t be completed. Undefined error"
        case .invalidRequest:
            return "The operation couldn’t be completed. Invalid request"
        case .failedDecodingResponse(let reason), .general(let reason):
            return reason
        }
    }
}

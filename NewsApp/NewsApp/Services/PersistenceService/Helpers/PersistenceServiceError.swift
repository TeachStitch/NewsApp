//
//  PersistenceServiceError.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

enum PersistenceServiceError: Error {
    case save(Error)
    case fetch(Error)
    case delete(Error)
    case general(String)
}

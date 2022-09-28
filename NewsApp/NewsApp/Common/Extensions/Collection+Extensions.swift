//
//  Collection+Extensions.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

extension Array where Element == URLQueryItem {
    init(_ dictionary: [String: LosslessStringConvertible]) {
        self = dictionary.map { URLQueryItem(name: $0, value: $1.description) }
    }
}

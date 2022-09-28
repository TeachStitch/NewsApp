//
//  TypeAliases.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import Foundation

typealias VoidClosure = () -> Void

typealias GenericClosure<T> = (T) -> Void

typealias ResultClosure<Success, Failure> = GenericClosure<Result<Success, Failure>> where Failure: Error

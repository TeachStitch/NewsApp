//
//  TableViewCellConfigurable.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import UIKit

protocol TableViewCellConfigurable: UITableViewCell {
    associatedtype Model
    
    var model: Model? { get set }
    func set(model: Model)
}

extension TableViewCellConfigurable {
    func set(model: Model) {
        self.model = model
    }
}

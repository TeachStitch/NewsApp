//
//  UITableView+Extensions.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import UIKit

extension UITableView {
    
    final func register<T: UITableViewCell>(_ cell: T.Type) {
        register(cell.self, forCellReuseIdentifier: cell.identifier)
    }
    
    final func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            assertionFailure(
                "Failed to dequeue a cell with identifier \(T.identifier) matching type \(T.self). Check that you registered the cell beforehand."
            )
            return nil
        }
                
        return cell
    }
    
    final func register<T: UITableViewHeaderFooterView>(_ supplementaryViewType: T.Type) {
        register(supplementaryViewType.self, forHeaderFooterViewReuseIdentifier: supplementaryViewType.identifier)
    }
    
    final func dequeueReusableSupplementaryView<T: UITableViewHeaderFooterView>() -> T? {
        guard let supplementaryView = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
            assertionFailure(
                "Failed to dequeue a supplementary view with identifier \(T.identifier) matching type \(T.self). "
                + "Check that you registered the supplementary view beforehand."
            )
            return nil
        }
        
        return supplementaryView
    }
}

//
//  ScrollTopextensionTableView.swift
//  Swifty_Proteins
//
//  Created by Yolankyi SERHII on 9/6/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit

//Extension to automatically scroll up
extension UITableView {
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func scrollToTop(animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        if self.hasRowAtIndexPath(indexPath: indexPath) {
            self.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
}

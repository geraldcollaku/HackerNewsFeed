//
//  CellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.05.26.
//

import UIKit

public struct CellController {
    let id: AnyHashable
    let datasource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let datasourcePrefetching: UITableViewDataSourcePrefetching?
        
    public init(id: AnyHashable, _ datasource: UITableViewDataSource) {
        self.id = id
        self.datasource = datasource
        self.delegate = datasource as? UITableViewDelegate
        self.datasourcePrefetching = datasource as? UITableViewDataSourcePrefetching
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//
//  CellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.05.26.
//

import UIKit

public struct CellController {
    let id: any Hashable & Sendable
    let datasource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let datasourcePrefetching: UITableViewDataSourcePrefetching?
        
    public init(id: any Hashable & Sendable, _ datasource: UITableViewDataSource) {
        self.id = id
        self.datasource = datasource
        self.delegate = datasource as? UITableViewDelegate
        self.datasourcePrefetching = datasource as? UITableViewDataSourcePrefetching
    }
}

extension CellController: nonisolated Equatable {
    public nonisolated static func == (lhs: CellController, rhs: CellController) -> Bool {
     AnyHashable(lhs.id) == AnyHashable(rhs.id)
    }
}

extension CellController: nonisolated Hashable {
    public nonisolated func hash(into hasher: inout Hasher) {
        let id = AnyHashable(self.id)
        hasher.combine(id)
    }
}

//
//  MainQueueDispatchDecorator.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 21.03.26.
//

import Combine
import Foundation
import HackerNewsFeed

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
           return DispatchQueue.main.async {
                completion()
            }
        }
        
        completion()
    }
}


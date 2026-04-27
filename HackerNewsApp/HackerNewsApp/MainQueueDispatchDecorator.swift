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

extension MainQueueDispatchDecorator: StoryLoader where T == StoryLoader {
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        return decoratee.loadStory(with: id) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

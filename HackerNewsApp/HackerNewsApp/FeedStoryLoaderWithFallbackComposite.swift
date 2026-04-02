//
//  FeedStoryLoaderWithFallbackComposite.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 02.04.26.
//

import HackerNewsFeed

public final class FeedStoryLoaderWithFallbackComposite: StoryLoader {
    private let primary: StoryLoader
    private let fallback: StoryLoader
    
    public init(primary: StoryLoader, fallback: StoryLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: StoryLoaderTask {
        var wrapped: StoryLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadStory(with: id) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallback.loadStory(with: id, completion: completion)
            }
        }
        return task
    }
}

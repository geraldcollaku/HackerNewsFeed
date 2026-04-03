//
//  FeedStoryLoaderCacheDecorator.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 03.04.26.
//

import HackerNewsFeed

public final class FeedStoryLoaderCacheDecorator: StoryLoader {
    private let decoratee: StoryLoader
    private let cache: StoryCache
    
    public init(decoratee: StoryLoader, cache: StoryCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        return decoratee.loadStory(with: id) { [weak self] result in
            completion(result.map { story in
                self?.cache.saveIgnoringResult(story)
                return story
            })
        }
    }
}

private extension StoryCache {
    func saveIgnoringResult(_ story: Story) {
        save(story) { _ in }
    }
}

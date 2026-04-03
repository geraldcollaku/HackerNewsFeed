//
//  StoryLoaderSpy.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 03.04.26.
//

import HackerNewsFeed

class StoryLoaderSpy: StoryLoader {
    private(set) var messages = [(id: Int, completion: (StoryLoader.Result) -> Void)]()
    var loadedIds: [Int] {
        messages.map { $0.id }
    }
    
    private(set) var cancelledIds = [Int]()
    
    private struct Task: StoryLoaderTask {
        let callback: () -> Void
        func cancel() {
            callback()
        }
    }
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        messages.append((id, completion))
        return Task { [weak self] in
            self?.cancelledIds.append(id)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with story: Story, at index: Int = 0) {
        messages[index].completion(.success(story))
    }
}

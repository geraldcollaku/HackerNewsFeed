//
//  LocalStoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

public final class LocalStoryLoader: StoryLoader {
    private final class Task: StoryLoaderTask {
        private var completion: ((StoryLoader.Result) -> Void)?
        
        init(_ completion: @escaping (StoryLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: StoryLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public enum Error: Swift.Error {
        case failed
    }
    
    private let store: StoryStore
    
    public init(store: StoryStore) {
        self.store = store
    }
    
    public func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        let task = Task(completion)
        store.retrieve(for: id) { result in
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { localStory in
                    localStory.map { .success($0.toModel()) } ?? .failure(Error.failed)
                }
            )
        }
        return task
    }
}

private extension LocalStory {
    func toModel() -> Story {
        Story(
            id: id,
            title: title,
            text: text,
            author: author,
            score: score,
            createdAt: createdAt,
            totalComments: totalComments,
            comments: comments,
            type: type,
            url: url)
    }
}

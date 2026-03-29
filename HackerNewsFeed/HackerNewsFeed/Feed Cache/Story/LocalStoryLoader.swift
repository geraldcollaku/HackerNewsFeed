//
//  LocalStoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

public final class LocalStoryLoader {
    private final class LoadStoryDataTask: StoryLoaderTask {
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
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private let store: StoryStore
    
    public init(store: StoryStore) {
        self.store = store
    }
}

extension LocalStoryLoader {
    public typealias SaveResult = Result<Void, SaveError>
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ story: LocalStory, completion: @escaping (SaveResult) -> Void) {
        store.insert(story) { _ in
            completion(.failure(SaveError.failed))
        }
    }
}

extension LocalStoryLoader: StoryLoader {
    public typealias LoadResult = Result<Void, LoadError>

    public func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        let task = LoadStoryDataTask(completion)
        store.retrieve(for: id) { result in
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { localStory in
                    localStory.map { .success($0.toModel()) } ?? .failure(LoadError.notFound)
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

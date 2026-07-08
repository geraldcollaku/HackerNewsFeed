//
//  LocalStoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

public final class LocalStoryLoader {
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private let store: StoryStore
    
    public init(store: StoryStore) {
        self.store = store
    }
}

extension LocalStoryLoader: StoryCache {
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ story: Story) throws {
        do {
            try store.insert(story: story.toLocal())
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalStoryLoader: StoryLoader {
    public typealias LoadResult = Result<Story, LoadError>

    public func loadStory(with id: Int) throws -> Story {
        do {
            if let story = try store.retrieve(for: id) {
                return story.toModel()
            }
        } catch {
            throw LoadError.failed
        }
        throw LoadError.notFound
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

private extension Story {
    func toLocal() -> LocalStory {
        LocalStory(
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

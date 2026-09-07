 private class InMemoryFeedStore: FeedStore {
        private(set) var feedCache: CachedFeed?
        private var storyCache: [Int: LocalStory] = [:]
        
        init(feedCache: CachedFeed? = nil) {
            self.feedCache = feedCache
        }
        
        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
            feedCache =  CachedFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }
        
        func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
            completion(.success(feedCache))
        }
    }
    
    extension InMemoryFeedStore: StoryStore {
        
        func insert(_ story: LocalStory, completion: @escaping (StoryStore.InsertionResult) -> Void) {
            storyCache[story.id] = story
            completion(.success(()))
        }
        
        func retrieve(for id: Int, completion: @escaping (StoryStore.RetrievalResult) -> Void) {
            let story = storyCache[id]
            completion(.success((story)))
        }
    }

extension
        
        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
        
        static var withExpiredCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
        }
        
        static var withNonExpiredCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
        }
    }
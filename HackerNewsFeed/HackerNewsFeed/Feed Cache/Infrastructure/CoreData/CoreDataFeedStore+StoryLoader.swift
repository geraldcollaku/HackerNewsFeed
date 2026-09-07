//
//  CoreDataFeedStore+StoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 30.03.26.
//

import CoreData

extension CoreDataFeedStore: StoryStore {
    public func insert(story: LocalStory) throws {
        try perfomSync { context in
            Result {
                let managedStory = try ManagedStory.item(from: story, in: context)
                
                try ManagedNews.find(id: story.id, in: context).map {
                    $0.story = managedStory
                }
                
                try context.save()
            }
        }
    }
    
    public func retrieve(for id: Int) throws -> LocalStory? {
        try perfomSync { context in
            Result {
                try ManagedStory.find(with: id, in: context)?.local
            }
        }
    }
}

//
//  ManagedNews.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 09.02.26.
//

import CoreData

@objc(ManagedNews)
class ManagedNews: NSManagedObject {
    @NSManaged var id: Int
    
    static func ids(from localFeed: [LocalFeedId], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedNews(context: context)
            managed.id = local.id
            return managed
        })
    }
    
    var local: LocalFeedId {
        LocalFeedId(id: id)
    }
}

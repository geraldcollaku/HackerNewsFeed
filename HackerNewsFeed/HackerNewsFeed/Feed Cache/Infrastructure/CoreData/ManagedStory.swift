//
//  ManagedStory.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 30.03.26.
//

import CoreData

@objc(ManagedStory)
class ManagedStory: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String?
    @NSManaged var text: String?
    @NSManaged var author: String?
    @NSManaged var score: Int64
    @NSManaged var createdAt: Date
    @NSManaged var totalComments: Int64
    @NSManaged var comments: Data?
    @NSManaged var type: String?
    @NSManaged var url: URL?
    @NSManaged var news: ManagedNews?
}

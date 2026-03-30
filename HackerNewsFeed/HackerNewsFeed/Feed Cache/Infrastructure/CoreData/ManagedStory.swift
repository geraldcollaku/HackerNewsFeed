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
    
    static func find(with id: Int, in context: NSManagedObjectContext) throws -> ManagedStory? {
        let request = NSFetchRequest<ManagedStory>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "id == %d", id)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    static func item(from localStory: LocalStory, in context: NSManagedObjectContext) throws -> ManagedStory {
        let managed = try find(with: localStory.id, in: context) ?? ManagedStory(context: context)
        managed.id = Int64(localStory.id)
        managed.title = localStory.title
        managed.text = localStory.text
        managed.author = localStory.author
        managed.score = Int64(localStory.score ?? 0)
        managed.createdAt = localStory.createdAt
        managed.totalComments = Int64(localStory.totalComments ?? 0)
        managed.comments = try? NSKeyedArchiver.archivedData(
            withRootObject: localStory.comments as Any,
            requiringSecureCoding: false)
        managed.type = localStory.type
        managed.url = localStory.url
        return managed
    }
    
    var local: LocalStory {
        let commentsArray = comments.flatMap {
            try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, NSNumber.self],
                from: $0) as? [Int]
        }
        
        return LocalStory(id: Int(id),
                   title: title,
                   text: text,
                   author: author,
                   score: Int(score),
                   createdAt: createdAt,
                   totalComments: Int(totalComments),
                   comments: commentsArray,
                   type: type,
                   url: url)
    }
}

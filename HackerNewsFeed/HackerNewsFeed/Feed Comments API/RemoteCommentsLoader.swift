//
//  RemoteCommentsLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 13.05.26.
//

import Foundation

public typealias RemoteCommentsLoader = RemoteLoader<[FeedComment]>

public extension RemoteCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedCommentsMapper.map)
    }
}

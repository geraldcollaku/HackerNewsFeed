//
//  RemoteFeedLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 24.12.25.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedId]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}

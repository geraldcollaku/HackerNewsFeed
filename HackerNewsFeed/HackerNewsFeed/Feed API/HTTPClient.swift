//
//  HTTPClient.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 26.12.25.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

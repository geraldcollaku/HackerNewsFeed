//
//  SharedTestHelpers.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 18.01.26.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}


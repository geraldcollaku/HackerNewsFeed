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

func anyData() -> Data {
    Data("any data".utf8)
}

func makeItemsJSON(_ items: [Int]) -> Data {
    let json = try! JSONSerialization.data(withJSONObject: ["ids": items])
    return json
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

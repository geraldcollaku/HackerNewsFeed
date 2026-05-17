//
//  FeedLocalizationTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 16.03.26.
//

import XCTest
import HackerNewsFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalizedKeyAndValuesExit(in: bundle, table)
    }
}

//
//  FeedCommentsLocalizationTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 17.05.26.
//

import XCTest
import HackerNewsFeed

class FeedCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "FeedComments"
        let bundle = Bundle(for: FeedCommentsPresenter.self)
        assertLocalizedKeyAndValuesExit(in: bundle, table)
    }
}


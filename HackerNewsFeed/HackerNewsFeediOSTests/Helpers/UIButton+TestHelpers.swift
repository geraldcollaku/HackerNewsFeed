//
//  UIButton+TestHelpers.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

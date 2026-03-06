//
//  UIButton+TestHelpers.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}

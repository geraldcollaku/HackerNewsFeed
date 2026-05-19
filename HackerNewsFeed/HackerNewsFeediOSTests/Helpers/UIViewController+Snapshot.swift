//
//  UIViewController+Snapshot.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 19.05.26.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone17(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        let dummyScene = (UIWindowScene.self as NSObject.Type).init() as! UIWindowScene
        self.init(windowScene: dummyScene)
        self.frame = CGRect(origin: .zero, size: configuration.size)
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargings
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargings
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return configuration.traitCollection
    }
    
    func snapshot() -> UIImage {
        let render = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: configuration.traitCollection))
        return render.image { action in
            layer.render(in: action.cgContext)
        }
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargings: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    static func iPhone17(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        SnapshotConfiguration(
            size: CGSize(width: 393, height: 852),
            safeAreaInsets: UIEdgeInsets(top: 62, left: 0, bottom: 34, right: 0),
            layoutMargings: UIEdgeInsets(top: 70, left: 8, bottom: 42, right: 8),
            traitCollection: UITraitCollection(mutations: { traits in
                traits.forceTouchCapability = .unavailable
                traits.layoutDirection = .leftToRight
                traits.preferredContentSizeCategory = contentSize
                traits.userInterfaceIdiom = .phone
                traits.verticalSizeClass = .regular
                traits.displayScale = 3
                traits.displayGamut = .P3
                traits.userInterfaceStyle = style
            })
        )
    }
}

//
//  DebuggingSceneDelegate.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 04.04.26.
//

#if DEBUG
import UIKit
import HackerNewsFeed

class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebuggingFailingHTTPClient(connectivity: connectivity)
        }
        return super.makeRemoteClient()
    }
    
}

private class DebuggingFailingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        switch connectivity {
        case "online":
            completion(.success(makeSuccessfulResponse(for: url)))
        default:
            completion(.failure(NSError(domain: "offline", code: 0)))
        }
        return Task()
    }
    
    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://hacker-news.firebaseio.com/v0/newstories.json":
            return makeFeedIdData()
        default:
            return makeStoryData()
        }
    }
    
    private func makeFeedIdData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [1, 2])
    }
    
    private func makeStoryData() -> Data {
        let story: [String: Any] = [
            "id": 1,
            "title": "a title",
            "by": "an author",
            "score": 10,
            "time": 1000,
            "descendants": 0,
            "type": "story",
            "url": "https://a-url.com"
        ]
        return try! JSONSerialization.data(withJSONObject: story)
    }
}
#endif

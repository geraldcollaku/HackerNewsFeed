//
//  HTTPURLResponse+StatusCode.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 27.03.26.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200 
    }
}

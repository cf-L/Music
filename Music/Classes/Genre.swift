//
//  Genre.swift
//  Pods-Music_Example
//
//  Created by lcf on 2018/11/26.
//

import UIKit

public class Genre: NSObject {
    public var title: String
    public var value: String
    
    public init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    public static func ==(lhs: Genre, rhs: Genre) -> Bool {
        return lhs.value == rhs.value
    }
}

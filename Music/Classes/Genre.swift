//
//  Genre.swift
//  Pods-Music_Example
//
//  Created by lcf on 2018/10/19.
//

import UIKit

public class Genre: NSObject {
    
    public var title: String!
    public var value: String!
    
    public init(title: String, value: String) {
        super.init()
        self.title = title
        self.value = value
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        return value == (object as? Genre)?.value
    }
}

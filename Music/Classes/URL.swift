//
//  URL.swift
//  Music
//
//  Created by lcf on 2018/11/26.
//

import UIKit

public extension URL {
    
    public func parameter(_ param: String) -> String? {
        let urlComponents = URLComponents(string: self.absoluteString)
        if let queryItems = urlComponents?.queryItems as [NSURLQueryItem]? {
            return queryItems.filter({ $0.name == param }).first?.value
        }
        return nil
    }
}

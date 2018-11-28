//
//  Music.swift
//  Pods-Music_Example
//
//  Created by lcf on 2018/11/26.
//

import UIKit

public enum MusicSource: Int {
    case soundCloud
    case youtube
}

public enum MusicKind {
    case top(limit: Int)
    case trending
    
    var description: String {
        switch self {
        case .top(_):
            return "top"
        case .trending:
            return "trending"
        }
    }
}

public enum Operation {
    case load(genre: Genre)
    case search(text: String, isRelatedId: Bool)
}

public enum Order: String {
    case relevance
    case date
    case viewCount
}

public struct Next {
    public var source: MusicSource
    public var operation: Operation
    public var pageToken: String?
    public var offset: Int
    public var limit: Int
    
    public var order = Order.viewCount
    
    public init(source: MusicSource, operation: Operation, pageToken: String?) {
        self.source = source
        self.operation = operation
        self.pageToken = pageToken
        
        var offset = 0
        var limit = 0
        
        if let token = pageToken, let url = URL(string: token) {
            if let offsetString = url.parameter("offset") {
                offset = Int(offsetString) ?? 0
            }
            
            if let limitString = url.parameter("limit") {
                limit = Int(limitString) ?? 0
            }
        }
        
        self.offset = offset
        self.limit = limit
    }
    
    public var hasMore: Bool {
        get {
            return pageToken != nil
        }
    }
}

public protocol Music: class {
    
    typealias LoadCompleted = (_ error: Error?, _ next: Next?, _ tracks: [Track]?) -> Void
    typealias FetchTrackURLCompleted = (_ errpr: Error?, _ url: URL?) -> Void
    
    var list: [Genre] { get }
    var source : MusicSource { get }
    var clientIDs: [String]? { get set }
    var pageLimit: Int { get set }
    var limitPatterns: [String]? { get set }
    var kind: MusicKind { get set}
    
    func reload(genre: Genre, completed: LoadCompleted?)
    func loadList(genre: Genre, completed: Music.LoadCompleted?)
    func query(text: String, isRelatedId: Bool, completed: Music.LoadCompleted?)
    func next(next: Next, completed: Music.LoadCompleted?)
    func fetchPlayableURL(track: Track, completed: FetchTrackURLCompleted?)
}

public extension Music {
    func relatedList(relatedId: String, completed: Music.LoadCompleted?) {
        query(text: relatedId, isRelatedId: source == .youtube, completed: completed)
    }
}


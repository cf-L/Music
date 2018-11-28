//
//  MusicManager.swift
//  Alamofire
//
//  Created by lcf on 2018/11/26.
//

import UIKit

public class MusicManager: NSObject {
    
    public static let shared = MusicManager()
    
    public var currentSource: MusicSource = .soundCloud
    
    public var limitPatterns: [String] = [] {
        didSet {
            musics.forEach{ $0.limitPatterns = limitPatterns }
        }
    }
    
    public var clientIDs: [String] = [] {
        didSet {
            musics.forEach{ $0.clientIDs = clientIDs }
        }
    }
    
    private lazy var musics: [Music] = {
        let musics: [Music] = [SoundCloud(), Youtube()]
        return musics
    }()
    
    public var music: Music {
        get {
            return musics.filter({ $0.source == currentSource }).first!
        }
    }
    
    @discardableResult
    public func switchSource(_ source: MusicSource) -> MusicManager {
        self.currentSource = source
        return self
    }
}

// MARK: - Helper
public extension MusicManager {
    
    public static func match(text: String?, regex: NSRegularExpression?) -> Bool {
        guard let text = text, let regex = regex else { return false }
        
        let range = NSRange(location: 0, length: text.characters.count)
        return regex.matches(in: text, options: [], range: range).count > 0
    }
}

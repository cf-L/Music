//
//  Track.swift
//  Music
//
//  Created by lcf on 2018/11/26.
//

import UIKit
import RealmSwift

public class Track: Object {
    @objc public dynamic var id: String?
    @objc public dynamic var name: String? = nil
    @objc public dynamic var artworkURL: String? = nil
    @objc public dynamic var coverURL: String? = nil
    @objc public dynamic var artist: String? = nil
    @objc public dynamic var isVideo: Bool = false
    /// ms
    @objc public dynamic var duration: Int = 0
    @objc public dynamic var createAt: Date? = nil
    
    @objc public dynamic var snippetDescription: String?
    @objc public dynamic var viewCount = 0
    @objc public dynamic var likeCount = 0
    @objc public dynamic var dislikeCount = 0
}

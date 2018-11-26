//
//  Playlist.swift
//  Alamofire
//
//  Created by lcf on 2018/11/26.
//

import UIKit
import RealmSwift

public class Playlist: Object {
    @objc public dynamic var id: String? = nil
    @objc public dynamic var position: Int = -1
    @objc public dynamic var name: String? = nil
    @objc public dynamic var date: Date? = nil
    
    let tracks = List<Track>()
}

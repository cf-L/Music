//
//  MusicStorage+Playlist.swift
//  Alamofire
//
//  Created by lcf on 2018/11/26.
//

import UIKit

public extension MusicStorage {
    
    public var totalPlaylist: Int {
        get {
            return playlists.count
        }
    }
    
    public var playlists: [Playlist] {
        return realm.objects(Playlist.self).map{ return $0 }
    }
    
    public func createPlaylist(name: String?) {
        let playlist = Playlist()
        
        playlist.id = UUID().uuidString
        playlist.name = name
        playlist.position = maxPosition + 1
        playlist.date = Date()
        
        try! realm.write {
            realm.add(playlist)
        }
    }
    
    public func removePlaylist(playlist: Playlist) {
        let position = playlist.position
        let tailPlaylists = realm.objects(Playlist.self).filter("position > \(position)")
        
        try! realm.write {
            tailPlaylists.forEach{ $0.position -= 1 }
            realm.delete(playlist)
        }
    }
    
    public func add(tracks: [Track], to playlist: Playlist) {
        try! realm.write {
            realm.add(tracks)
            playlist.tracks.append(objectsIn: tracks)
        }
    }
    
    public func remove(tracks: [Track]) {
        try! realm.write {
            realm.delete(tracks)
        }
    }
    
    public func update(playlist: Playlist, name: String?) {
        try! realm.write {
            playlist.name = name
        }
    }
    
    public func move(playlist: Playlist, to index: Int) {
        try! realm.write {
            let currentIndex = playlist.position
            let destiation = index + 1
            
            if currentIndex > destiation {
                
                let playlists = realm.objects(Playlist.self)
                    .filter("position >= \(destiation) and position < \(currentIndex)")
                
                try! realm.write {
                    playlists.forEach{ $0.position += 1 }
                    playlist.position = destiation
                }
                
            } else if currentIndex < destiation {
                
                let playlists = realm.objects(Playlist.self)
                    .filter("position > \(currentIndex) and position <= \(destiation)")
                
                try! realm.write {
                    playlists.forEach{ $0.position -= 1 }
                    playlist.position = destiation
                }
            }
        }
    }
}

// MARK: - Private
private extension MusicStorage {
    
    private var maxPosition: Int {
        get {
            return realm.objects(Playlist.self)
                .sorted(byKeyPath: "position", ascending: true).last?.position ?? 0
        }
    }
}

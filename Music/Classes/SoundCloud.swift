//
//  SoundCloud.swift
//  Music
//
//  Created by lcf on 2018/11/26.
//

import UIKit
import Alamofire
import SwiftyJSON

public class SoundCloud: Music {
    
    public let list: [Genre] = [
        Genre(title: ("Trending Music"), value: "soundcloud%3Agenres%3Aall-music"),
        Genre(title: ("Trending Audio"), value: "soundcloud%3Agenres%3Aall-audio"),
        Genre(title: ("Alternative Rock"), value: "soundcloud%3Agenres%3Aalternativerock"),
        Genre(title: ("Ambient"), value: "soundcloud%3Agenres%3Aambient"),
        Genre(title: ("Classical"), value: "soundcloud%3Agenres%3Aclassical"),
        Genre(title: ("Country"), value: "soundcloud%3Agenres%3Acountry"),
        Genre(title: ("Dance & EDM"), value: "soundcloud%3Agenres%3Adanceedm"),
        Genre(title: ("Dancehall"), value: "soundcloud%3Agenres%3Adancehall"),
        Genre(title: ("Deep House"), value: "soundcloud%3Agenres%3Adeephouse"),
        Genre(title: ("Disco"), value: "soundcloud%3Agenres%3Adisco"),
        Genre(title: ("Drum & Bass"), value: "soundcloud%3Agenres%3Adrumbass"),
        Genre(title: ("Dubstep"), value: "soundcloud%3Agenres%3Adubstep"),
        Genre(title: ("Electronic"), value: "soundcloud%3Agenres%3Aelectronic"),
        Genre(title: ("Folk & Singer-Songwriter"), value: "soundcloud%3Agenres%3Afolksingersongwriter"),
        Genre(title: ("Hip Hop & Rap"), value: "soundcloud%3Agenres%3Ahiphoprap"),
        Genre(title: ("House"), value: "soundcloud%3Agenres%3Ahouse"),
        Genre(title: ("Indie"), value: "soundcloud%3Agenres%3Aindie"),
        Genre(title: ("Jazz & Blues"), value: "soundcloud%3Agenres%3Ajazzblues"),
        Genre(title: ("Latin"), value: "soundcloud%3Agenres%3Alatin"),
        Genre(title: ("Metal"), value: "soundcloud%3Agenres%3Ametal"),
        Genre(title: ("Piano"), value: "soundcloud%3Agenres%3Apiano"),
        Genre(title: ("Pop"), value: "soundcloud%3Agenres%3Apop"),
        Genre(title: ("R&B & Soul"), value: "soundcloud%3Agenres%3Arbsoul"),
        Genre(title: ("Reggae"), value: "soundcloud%3Agenres%3Areggae"),
        Genre(title: ("Reggaeton"), value: "soundcloud%3Agenres%3Areggaeton"),
        Genre(title: ("Rock"), value: "soundcloud%3Agenres%3Arock"),
        Genre(title: ("Soundtrack"), value: "soundcloud%3Agenres%3Asoundtrack"),
        Genre(title: ("Techno"), value: "soundcloud%3Agenres%3Atechno"),
        Genre(title: ("Trance"), value: "soundcloud%3Agenres%3Atrance"),
        Genre(title: ("Trap"), value: "soundcloud%3Agenres%3Atrap"),
        Genre(title: ("Trip Hop"), value: "soundcloud%3Agenres%3Atriphop"),
        Genre(title: ("World"), value: "soundcloud%3Agenres%3Aworld"),
        Genre(title: ("Audiobooks"), value: "soundcloud%3Agenres%3Aaudiobooks"),
        Genre(title: ("Business"), value: "soundcloud%3Agenres%3Abusiness"),
        Genre(title: ("Comedy"), value: "soundcloud%3Agenres%3Acomedy"),
        Genre(title: ("Entertainment"), value: "soundcloud%3Agenres%3Aentertainment"),
        Genre(title: ("Learning"), value: "soundcloud%3Agenres%3Alearning"),
        Genre(title: ("News & Politics"), value: "soundcloud%3Agenres%3Anewspolitics"),
        Genre(title: ("Religion & Spirituality"), value: "soundcloud%3Agenres%3Areligionspirituality"),
        Genre(title: ("Science"), value: "soundcloud%3Agenres%3Ascience"),
        Genre(title: ("Sports"), value: "soundcloud%3Agenres%3Asports"),
        Genre(title: ("Storytelling"), value: "soundcloud%3Agenres%3Astorytelling"),
        Genre(title: ("Technology"), value: "soundcloud%3Agenres%3Atechnology")
    ]
    
    public let source: MusicSource = .soundCloud
    public var clientIDs: [String]?
    public var pageLimit: Int = 20
    public var limitPatterns: [String]?
    public var kind: MusicKind = .trending
    
    fileprivate var baseLink: String {
        get {
            return "https://api-v2.soundcloud.com/charts?kind=\(self.kind.description)"
        }
    }
    fileprivate var fetchStreamLink = "https://api.soundcloud.com/i1/tracks/%@/streams"
    fileprivate var searchLink = "https://api-v2.soundcloud.com/search/tracks"
    
    fileprivate var isClientIDEmpty: Bool {
        get {
            return self.clientIDs == nil || self.clientIDs!.isEmpty
        }
    }
    
    public init() {
        
    }
    
    public func reload(genre: Genre, completed: Music.LoadCompleted?) {
        self.loadList(genre: genre, completed: completed)
    }
    
    public func loadList(genre: Genre, completed: Music.LoadCompleted?) {
        self.loadList(genre: genre, next: nil, completed: completed)
    }
    
    public func query(text: String, isRelatedId: Bool = false, completed: Music.LoadCompleted?) {
        self.query(text: text, next: nil, completed: completed)
    }
    
    public func next(next: Next, completed: Music.LoadCompleted?) {
        switch next.operation {
        case .load(let genre):
            self.loadList(genre: genre, next: next, completed: completed)
        case .search(let text, _):
            self.query(text: text, next: next, completed: completed)
        }
    }
    
    public func fetchPlayableURL(track: Track, completed: FetchTrackURLCompleted?) {
        
        guard !self.isClientIDEmpty else {
            let error = NSError(domain: "Sound cloud client id is empty", code: 0, userInfo: nil)
            completed?(error, nil)
            return
        }
        
        guard let id = track.id else {
            let error = NSError(domain: "Track id not found", code: 0, userInfo: nil)
            completed?(error, nil)
            return
        }
        
        let streamLink = String.init(format: fetchStreamLink, id)
        
        if let id = clientIDs?.first {
            let parameters: [String: Any] = ["client_id": id]
            
            request(streamLink, method: .get, parameters: parameters).responseJSON { (response) in
                var url: URL?
                
                if response.result.isSuccess && response.value != nil {
                    let json = JSON(response.value!)
                    let urlString = json["http_mp3_128_url"].stringValue
                    url = URL(string: urlString)
                }
                
                completed?(nil, url)
            }
        }
    }
    
    // MARK: Private
    
    private func checkClientID(completed: Music.LoadCompleted?) -> Bool {
        if  self.isClientIDEmpty {
            let error = NSError(domain: "Sound cloud client id is empty", code: 0, userInfo: nil)
            completed?(error, nil, nil)
            return false
        }
        return true
    }
    
    private func buildTrack(jsons: [JSON], isSearch: Bool = false) -> [Track] {
        var filterJSON = jsons
        if let jsons = self.filterTrack(json: jsons) {
            filterJSON = jsons
        }
        
        var tracks = [Track]()
        for json in filterJSON {
            let info = isSearch ? json : json["track"]
            let track = Track()
            track.id = "\(info["id"].intValue)"
            track.artworkURL = info["artwork_url"].string
            track.isVideo = false
            track.name = info["title"].string
            track.duration = info["duration"].intValue
            track.coverURL = track.artworkURL?.replacingOccurrences(of: "-large", with: "-t500x500")
            track.artist = info["publisher_metadata"]["artist"].string
            tracks.append(track)
        }
        
        return tracks
    }
    
    private func handlerLoadResult(response: DataResponse<Any>, operation: Operation, isSearch: Bool = false, completed: Music.LoadCompleted?) {
        switch response.result {
        case .success:
            var tracks = [Track]()
            var next: Next?
            
            if let value = response.result.value {
                let json = JSON(value)
                tracks = self.buildTrack(jsons: json["collection"].arrayValue, isSearch: isSearch)
                next = Next(source: source, operation: operation, pageToken: json["next_href"].string)
            }
            
            if case .load(_) = operation, case .top(let topLimit) = self.kind, topLimit > 0 {
                if let offset = next?.offset, let limit = next?.limit {
                    if offset > topLimit {
                        let remain = topLimit - (offset - limit)
                        if tracks.indices.contains(remain) {
                            tracks = Array(tracks[0..<remain])
                            next = nil
                        }
                    }
                }
            }
            
            completed?(nil, next, tracks)
            
        case .failure(let error):
            completed?(error, nil, nil)
        }
    }
    
    private func loadList(genre: Genre, next: Next?, completed: Music.LoadCompleted?) {
        guard self.checkClientID(completed: completed) else { return }
        
        let link = next?.hasMore == true && next!.pageToken != nil ? next!.pageToken! : self.baseLink
        let parameters: [String: Any] = ["genre": genre.value, "limit": pageLimit, "client_id": clientIDs!.first!]
        
        request(link, method: .get, parameters: parameters).responseJSON { (response) in
            self.handlerLoadResult(response: response, operation: Operation.load(genre: genre), completed: completed)
        }
    }
    
    private func query(text: String, next: Next?, completed: Music.LoadCompleted?) {
        guard self.checkClientID(completed: completed) else { return }
        
        var link = self.searchLink
        var parameters: [String: Any] = ["client_id": clientIDs!.first!]
        
        if let next = next, case let .search(text) = next.operation, let token = next.pageToken {
            link = token
        } else {
            parameters["q"] = text
            parameters["limit"] = pageLimit
        }
        
        request(link, method: .get, parameters: parameters).responseJSON { (response) in
            self.handlerLoadResult(response: response, operation: Operation.search(text: text, isRelatedId: false), isSearch: true, completed: completed)
        }
    }
    
    private func filterTrack(json: [JSON]?) -> [JSON]? {
        guard let limitPatterns = self.limitPatterns else { return json }
        
        let limitedPatterns = limitPatterns.map { (item) -> String in
            var pattern = item
            pattern = pattern.replacingOccurrences(of: "-", with: "\\s*\\-?\\s*")
            pattern = pattern.replacingOccurrences(of: ".", with: ".?")
            pattern = pattern.replacingOccurrences(of: " ", with: ".?")
            return pattern
        }
        
        return json?.filter({ (track) -> Bool in
            for pattern in (limitedPatterns ?? []) {
                let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                
                if MusicManager.match(text: track["title"].string, regex: regex)
                    || MusicManager.match(text: track["user"]["username"].string, regex: regex)
                    || MusicManager.match(text: track["tag_list"].string, regex: regex)
                    || MusicManager.match(text: track["permalink"].string, regex: regex) {
                    
                    return false
                }
            }
            
            return true
        })
    }
}



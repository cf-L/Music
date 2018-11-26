//
//  Youtube.swift
//  Alamofire
//
//  Created by lcf on 2018/11/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import XCDYouTubeKit
import Common

public class Youtube: Music {
    
    // MARK: Public properties
    public let list: [Genre] = [
        Genre(title: __("Trending"), value: "PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI"),
        Genre(title: __("Pop Music"), value: "PLDcnymzs18LWrKzHmzrGH1JzLBqrHi3xQ"),
        Genre(title: __("House Music"), value: "PLhInz4M-OzRUsuBj8wF6383E7zm2dJfqZ"),
        Genre(title: __("Latin Music"), value: "PLcfQmtiAG0X-fmM85dPlql5wfYbmFumzQ"),
        Genre(title: __("Electronic Music"), value: "PLFPg_IUxqnZNnACUGsfn50DySIOVSkiKI"),
        Genre(title: __("Hip Hop Music"), value: "PLH6pfBXQXHEC2uDmDy5oi3tHW6X8kZ2Jo"),
        Genre(title: __("Reggae"), value: "PLYAYp5OI4lRLf_oZapf5T5RUZeUcF9eRO"),
        Genre(title: __("Trap"), value: "PLL4IwRtlZcbvbCM7OmXGtzNoSR0IyVT02"),
        Genre(title: __("Pop Rock"), value: "PLr8RdoI29cXIlkmTAQDgOuwBhDh3yJDBQ"),
        Genre(title: __("Country"), value: "tFJCfRG7hi_OjIAyCriNUT2"),
        Genre(title: __("R&B"), value: "PLFRSDckdQc1th9sUu8hpV1pIbjjBgRmDw"),
        Genre(title: __("Asian Music"), value: "PL0zQrw6ZA60Z6JT4lFH-lAq5AfDnO2-aE"),
        Genre(title: __("Mexican Music"), value: "PLXupg6NyTvTxw5-_rzIsBgqJ2tysQFYt5"),
        Genre(title: __("Soul"), value: "PLQog_FHUHAFUDDQPOTeAWSHwzFV1Zz5PZ"),
        Genre(title: __("Rhythm & Blues"), value: "PLWNXn_iQ2yrKzFcUarHPdC4c_LPm"),
        Genre(title: __("Christian Music"), value: "PLLMA7Sh3JsOQQFAtj1no-_keicrqjEZDm"),
        Genre(title: __("Hard Rock"), value: "PL9NMEBQcQqlzwlwLWRz5DMowimCk88FJk"),
        Genre(title: __("Heavy Metal"), value: "PLfY-m4YMsF-OM1zG80pMguej_Ufm8t0VC"),
        Genre(title: __("Classical Music"), value: "PLVXq77mXV53-Np39jM456si2PeTrEm9Mj"),
        Genre(title: __("Alternative Rock"), value: "PL47oRh0-pTouthHPv6AbALWPvPJHlKiF7"),
        ]
    
    public let source: MusicSource = .youtube
    public var clientIDs: [String]?
    public var pageLimit: Int = 20
    public var limitPattern: String?
    public var kind: MusicKind = .trending
    
    fileprivate var onlineIDs: [String] = []
    
    // MARK: Private properties
    fileprivate var isClientIDEmpty: Bool {
        get {
            return self.onlineIDs.isEmpty && (self.clientIDs == nil || self.clientIDs!.isEmpty)
        }
    }
    
    fileprivate var key: String? {
        get {
            guard !self.isClientIDEmpty else { return nil }
            if self.onlineIDs.isEmpty == false {
                let index = arc4random() % UInt32(self.onlineIDs.count)
                return self.onlineIDs[Int(index)]
            }
            
            let index = arc4random() % UInt32(clientIDs!.count)
            return clientIDs![Int(index)]
        }
    }
    
    fileprivate var playListBaseLink: String? {
        get {
            guard let key = self.key else { return nil }
            
            return "https://www.googleapis.com/youtube/v3/playlistItems?" +
                "part=snippet&fields=items%2Ckind%2CnextPageToken%2CprevPageToken%2CtokenPagination" +
            "&key=\(key)&maxResults=\(pageLimit)"
        }
    }
    
    fileprivate var itemDetailLink: String? {
        get {
            guard let key = self.key else { return nil }
            
            return "https://www.googleapis.com/youtube/v3/videos?part=contentDetails%2Csnippet%2Cstatistics&key=\(key)"
        }
    }
    
    fileprivate var searchBaseBaseLink: String? {
        guard let key = self.key else { return nil }
        
        return "https://www.googleapis.com/youtube/v3/search?" +
            "part=snippet&type=video&videoCategoryId=10&videoDefinition=high" +
            "&fields=items%2Ckind%2CnextPageToken%2CprevPageToken%2CtokenPagination&key=\(key)&" +
        "maxResults=\(pageLimit)"
    }
    
    // MARK: Public methods
    public init() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name.init("ParamsUpdatedNotification"),
            object: nil,
            queue: OperationQueue.main) { (notification) in
                
                self.onlineIDs = MusicManager.shared.clientID()
        }
    }
    
    public func reload(genre: Genre, completed: Music.LoadCompleted?) {
        self.loadList(genre: genre, completed: completed)
    }
    
    public func loadList(genre: Genre, completed: Music.LoadCompleted?) {
        self.loadList(genre: genre, next: nil, completed: completed)
    }
    
    public func query(text: String, isRelatedId: Bool, completed: Music.LoadCompleted?) {
        self.query(text: text, isRelatedId: isRelatedId, next: nil, completed: completed)
    }
    
    public func fetchPlayableURL(track: Track, completed: FetchTrackURLCompleted?) {
        guard let id = track.id else {
            let error = NSError(domain: "Track id not found", code: 0, userInfo: nil)
            completed?(error, nil)
            return
        }
        
        let preferredVideoQualities = [NSNumber.init(value: XCDYouTubeVideoQuality.HD720.rawValue),
                                       NSNumber.init(value: XCDYouTubeVideoQuality.medium360.rawValue),
                                       NSNumber.init(value: XCDYouTubeVideoQuality.small240.rawValue)]
        
        XCDYouTubeClient.default().getVideoWithIdentifier(id) { (video, error) in
            
            if let video = video {
                var url: URL? = nil
                
                for videoQuality in preferredVideoQualities {
                    if let streamURL = video.streamURLs[videoQuality] {
                        url = streamURL
                        break
                    }
                }
                
                completed?(nil, url)
            } else {
                completed?(error, nil)
            }
        }
    }
    
    // MARK: Private Methods
    
    private func checkClientID(completed: Music.LoadCompleted?) -> Bool {
        if  self.isClientIDEmpty {
            let error = NSError(domain: "Sound cloud client id is empty", code: 0, userInfo: nil)
            completed?(error, nil, nil)
            return false
        }
        return true
    }
    
    private func loadList(genre: Genre, next: Next?, completed: Music.LoadCompleted?) {
        guard var link = playListBaseLink else {
            let error = NSError(domain: "Sound cloud client id is empty", code: 0, userInfo: nil)
            completed?(error, nil, nil)
            return
        }
        
        link = "\(link)&playlistId=\(genre.value)"
        
        if let token = next?.pageToken {
            link += "&pageToken=\(token)"
        }
        
        request(link, method: .get).responseJSON { (response) in
            self.handlerLoadListResult(response: response, operation: Operation.load(genre: genre), completed: completed)
        }
    }
    
    private func query(text: String, isRelatedId: Bool = false, next: Next?, completed: Music.LoadCompleted?) {
        guard var link = searchBaseBaseLink else {
            let error = NSError(domain: "Sound cloud client id is empty", code: 0, userInfo: nil)
            completed?(error, nil, nil)
            return
        }
        
        if isRelatedId {
            link += "&relatedToVideoId=\(text)"
        } else {
            link += "&q=\(text)"
        }
        
        if let token = next?.pageToken {
            link += "&pageToken=\(token)"
        }
        
        // 2018.3.14 添加选择排序功能 &order=viewCount
        link += "&order=" + (next?.order.rawValue ?? "viewCount")
        
        request(link, method: .get).responseJSON { (response) in
            self.handlerSearchResult(response: response, operation: Operation.search(text: text, isRelatedId: isRelatedId), completed: completed)
        }
    }
    
    public func next(next: Next, completed: Music.LoadCompleted?) {
        switch next.operation {
        case .load(let genre):
            self.loadList(genre: genre, next: next, completed: completed)
        case .search(let text, let isRelatedId):
            self.query(text: text, isRelatedId: isRelatedId, next: next, completed: completed)
        }
    }
    
    private func fetchItemDetail(itemIDs: [String], next: Next?, completed: Music.LoadCompleted?) {
        
        guard var link = itemDetailLink else {
            let error = NSError(domain: "Sound cloud client id is empty", code: 0, userInfo: nil)
            completed?(error, nil, nil)
            return
        }
        
        let param = itemIDs.joined(separator: ",")
        link += "&id=\(param)"
        
        request(link, method: .get).responseJSON { (response) in
            switch response.result {
            case .success:
                var tracks = [Track]()
                
                if let value = response.result.value {
                    let json = JSON(value)
                    tracks = self.buildTrack(jsons: json["items"].arrayValue)
                }
                
                completed?(nil, next, tracks)
                
            case .failure(let error):
                completed?(error, nil, nil)
            }
        }
    }
    
    private func buildTrack(jsons: [JSON]) -> [Track] {
        var filterJSON = jsons
        if let jsons = self.filterTrack(json: jsons) {
            filterJSON = jsons
        }
        
        var tracks = [Track]()
        for json in filterJSON {
            let track = Track()
            track.id = json["id"].stringValue
            track.artworkURL = json["snippet"]["thumbnails"]["default"]["url"].string
            track.isVideo = true
            track.name = json["snippet"]["title"].string
            track.duration = formattedDuration(durationStr: json["contentDetails"]["duration"].stringValue) * 1000
            track.coverURL = json["snippet"]["thumbnails"]["high"]["url"].string
            track.artist = json["snippet"]["channelTitle"].string
            
            track.snippetDescription = json["snippet"]["description"].string
            track.viewCount = json["statistics"]["viewCount"].intValue
            track.likeCount = json["statistics"]["likeCount"].intValue
            track.dislikeCount = json["statistics"]["dislikeCount"].intValue
            tracks.append(track)
        }
        
        return tracks
    }
    
    private func handlerLoadListResult(response: DataResponse<Any>, operation: Operation, completed: Music.LoadCompleted?) {
        switch response.result {
        case .success:
            
            if let value = response.result.value {
                let json = JSON(value)
                let nextToken = json["nextPageToken"].string
                
                let itemIDs = json["items"].arrayValue.map({ $0["snippet"]["resourceId"]["videoId"].stringValue })
                
                var next = Next(source: .youtube, operation: operation, pageToken: nextToken)
                
                self.fetchItemDetail(itemIDs: itemIDs, next: next, completed: completed)
            } else {
                completed?(nil, nil, [])
            }
            
        case .failure(let error):
            completed?(error, nil, nil)
        }
    }
    
    private func handlerSearchResult(response: DataResponse<Any>, operation: Operation, completed: Music.LoadCompleted?) {
        switch response.result {
        case .success:
            
            if let value = response.result.value {
                let json = JSON(value)
                let nextToken = json["nextPageToken"].string
                
                let itemIDs = json["items"].arrayValue.map({ $0["id"]["videoId"].stringValue })
                
                var next = Next(source: .youtube, operation: operation, pageToken: nextToken)
                
                self.fetchItemDetail(itemIDs: itemIDs, next: next, completed: completed)
            } else {
                completed?(nil, nil, [])
            }
            
        case .failure(let error):
            completed?(error, nil, nil)
        }
    }
    
    private func formattedDuration(durationStr: String) -> Int {
        var formattedDuration = durationStr.replacingOccurrences(of: "PT", with: "")
        formattedDuration = formattedDuration.replacingOccurrences(of: "H", with: ":")
        formattedDuration = formattedDuration.replacingOccurrences(of: "M", with: ":")
        formattedDuration = formattedDuration.replacingOccurrences(of: "S", with: "")
        
        if formattedDuration[formattedDuration.index(before: formattedDuration.endIndex)] == ":" {
            formattedDuration = formattedDuration.appending("0")
        }
        
        let components = formattedDuration.components(separatedBy: ":")
        
        if components.count == 3 {
            if let hour = Int(components[0]), let minute = Int(components[1]), let second = Int(components[2]) {
                return hour*3600 + minute*60 + second
            }
        }
        
        if components.count == 2 {
            if let minute = Int(components[0]), let second = Int(components[1]) {
                return minute*60 + second
            }
        }
        
        if components.count == 1 {
            if let second = Int(components[0]) {
                return second
            }
        }
        
        return 0
    }
    
    private func filterTrack(json: [JSON]?) -> [JSON]? {
        guard let limitPattern = self.limitPattern else { return json }
        
        let limitedPatterns = Params.named(limitPattern).array?.map { (item) -> String in
            var pattern = item.stringValue
            pattern = pattern.replacingOccurrences(of: "-", with: "\\s*\\-?\\s*")
            pattern = pattern.replacingOccurrences(of: ".", with: ".?")
            pattern = pattern.replacingOccurrences(of: " ", with: ".?")
            return pattern
        }
        
        return json?.filter({ (track) -> Bool in
            for pattern in (limitedPatterns ?? []) {
                let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                
                if MusicManager.match(text: track["snippet"]["title"].string, regex: regex)
                    || MusicManager.match(text: track["snippet"]["channelTitle"].string, regex: regex) {
                    
                    return false
                }
            }
            
            return true
        })
    }
}

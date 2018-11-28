//
//  MusicPlayerObserver.swift
//  Alamofire
//
//  Created by lcf on 2018/11/27.
//

import UIKit

@objc public protocol MusicPlayerObserver {
    
    @objc optional func musicPlayer(player: MusicPlayer, didSet tracks: [Track])
    @objc optional func musicPlayer(player: MusicPlayer, Loading track: Track, at index: Int)
    @objc optional func musicPlayer(player: MusicPlayer, didLoad track: Track, at index: Int)
    @objc optional func musicPlayer(player: MusicPlayer, buffering track: Track, at index: Int)
    
    @objc optional func musicPlayer(player: MusicPlayer, startPlaying track: Track, at index: Int)
    @objc optional func musicPlayer(player: MusicPlayer, didPause track: Track, at index: Int)
    
    @objc optional func musicPlayer(player: MusicPlayer, didSeekTo second: Double)
    @objc optional func musicPlayer(player: MusicPlayer, volumnChanged volumn: Float)
    
    @objc optional func musicPlayer(player: MusicPlayer, sleepTimeChanged timeInterval: TimeInterval)
    @objc optional func musicPlayer(player: MusicPlayer, didReachSleepTime: Bool)
}

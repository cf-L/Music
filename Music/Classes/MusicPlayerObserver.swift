//
//  MusicPlayerObserver.swift
//  Alamofire
//
//  Created by lcf on 2018/11/27.
//

import UIKit

@objc public protocol MusicPlayerObserver {
    
    @objc optional func musicPlayer(player: MusicPlayer, didSet tracks: [Track])
    @objc optional func musicPlayer(player: MusicPlayer, willPlaying track: Track)
    @objc optional func musicPlayer(player: MusicPlayer, Loading track: Track)
    @objc optional func musicPlayer(player: MusicPlayer, didLoad track: Track)
    @objc optional func musicPlayer(player: MusicPlayer, buffering track: Track)
    
    @objc optional func musicPlayer(player: MusicPlayer, startPlaying track: Track)
    @objc optional func musicPlayer(player: MusicPlayer, didPause track: Track)
    @objc optional func musicPlayer(player: MusicPlayer, willFinish track: Track)
    
    @objc optional func musicPlayer(player: MusicPlayer, didSeekTo second: Double)
    @objc optional func musicPlayer(player: MusicPlayer, didChanged volumn: Float)
    
    @objc optional func musicPlayer(player: MusicPlayer, sleepTimeChanged timeInterval: TimeInterval)
}

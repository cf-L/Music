//
//  MusicPlayer.swift
//  Alamofire
//
//  Created by lcf on 2018/11/27.
//

import UIKit
import AVFoundation
import MediaPlayer
import SDWebImage

public class MusicPlayer: NSObject {

    static let shared = MusicPlayer()
    
    public var observers = [ObjectIdentifier: MusicPlayerObserver]()
    public var setting = Setting()
    
    public var tracks = [Track]()
    public var progressView = [ObjectIdentifier: UISlider]()
    
    public var player = AVPlayer()
    public var playerLayer = AVPlayerLayer()
    
    private var timeObserver: Any?
    private var isSeeking: Bool = false
    private var timer: Timer = Timer()
    
    private(set) var track: Track?
    private(set) var index: Int?
    
    public override init() {
        super.init()
        playerLayer.player = player
        playerLayer.backgroundColor = UIColor.black.cgColor
        setupNotification()
    }
    
    public func play(tracks: [Track]) {
        self.tracks = tracks
        progressView.values.forEach{ $0.value = 0 }
        player.replaceCurrentItem(with: nil)
        
        index = tracks.isEmpty ? nil : (setting.isShuffled ? randomIndex : 0)
        track = tracks.isEmpty || index == nil ? nil : tracks[index!]
        
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(timerHandler),
                                     userInfo: nil, repeats: true)
        
        observers.values.forEach{ $0.musicPlayer?(player: self, didSet: tracks) }
    }
    
    public func setEmpty() {
        play(tracks: [])
    }
    
    public func play(index: Int, start: Bool = true) {
        guard tracks.indices.contains(index) else { return }
        
        self.index = index
        track = tracks[index]
        
        player.currentItem?.asset.cancelLoading()
        player.replaceCurrentItem(with: nil)
        progressView.values.forEach{ $0.value = 0 }
        
        setting.isPlaying = false
        
        if start { play() }
    }
    
    public func remove(tracks: [Track]) {
        let originIndex = index
        
        for track in tracks {
            if let index = self.tracks.firstIndex(of: track) {
                self.tracks.remove(at: index)
            }
        }
        
        if self.tracks.isEmpty {
            setEmpty()
            return
        }
        
        guard let track = track else { return }
        
        if let index = tracks.firstIndex(of: track) {
            self.index = index
        } else {
            self.index = setting.isShuffled
                ? randomIndex
                : originIndex != nil && tracks.indices.contains(originIndex!) ? originIndex : 0
            
            player.replaceCurrentItem(with: nil)
            play()
        }
    }
    
    public func playNext() {
        switch setting.loopMode {
        case .list:
            if index != nil && index! + 1 >= tracks.count {
                pause()
            } else {
                toggleNext()
            }
        case .listLoop:
            toggleNext()
        case .single:
            seek(to: 0)
        }
    }
}

// MARK: - Player
public extension MusicPlayer {
    
    func play() {
        if track == nil {
            playNext()
            return
        }
        
        if player.currentItem == nil {
            load(track: track!, and: true)
        } else {
            player.play()
            setting.isPlaying = true
            
            if let index = index, let track = track {
                observers.values.forEach{ $0.musicPlayer?(player: self, startPlaying: track, at: index) }
            }
        }
    }
    
    func pause() {
        player.pause()
        setting.isPlaying = false
        
        if let index = index, let track = track {
            observers.values.forEach{ $0.musicPlayer?(player: self, didPause: track, at: index) }
        }
    }
    
    func forward() {
        guard !tracks.isEmpty else { return }
        let nextIndex = (index ?? 0) % tracks.count
        play(index: nextIndex, start: true)
    }
    
    func backward() {
        guard tracks.count > 1 else { return }
        let prevIndex = (index != nil ? index! - 1 : 0) % tracks.count
        play(index: prevIndex, start: true)
    }
    
    func seek(to time: Double) {
        guard player.status == .readyToPlay else { return }
        
        player.pause()
        
        if let timescale = player.currentItem?.duration.timescale, timescale != 0 {
            let timer = CMTime(seconds: time, preferredTimescale: timescale)
            player.seek(to: timer) { (finished) in
                self.observers.values.forEach{ $0.musicPlayer?(player: self, didSeekTo: timer.seconds) }
                if self.setting.isPlaying {
                    self.play()
                }
            }
        }
    }

    func seekForward() {
        guard player.currentItem != nil else { return }
        let time = player.currentTime().seconds + 10.0
        seek(to: time)
    }
    
    func seekBackward() {
        guard player.currentItem != nil else { return }
        let time = player.currentTime().seconds - 10.0
        seek(to: max(time, 0))
    }
}

// MARK: - Action
public extension MusicPlayer {
    
    @objc func progressValueDidChanged(slider: UISlider) {
        isSeeking = true
    }
    
    @objc func progressDidEndChanged(slider: UISlider) {
        isSeeking = false
        if let duration = track?.duration {
            let time = (slider.value / 100) * Float(duration / 1000)
            seek(to: Double(time))
        }
    }
    
    @objc func timerHandler() {
        guard !isSeeking else { return }
        
        let currentTime = player.currentTime().seconds
        
        if let duration = track?.duration {
            let value = currentTime * 100 / (Double(duration) / 1000)
            
            progressView.values.forEach{ $0.setValue(Float(value), animated: true) }
            observers.values.forEach{ $0.musicPlayer?(player: self, didSeekTo: value) }
        }
        
        if let date = setting.stopDate {
            let interval = date.timeIntervalSinceNow
            if interval < 0 {
                setting.stopDate = nil
                pause()
                observers.values.forEach{ $0.musicPlayer?(player: self, didReachSleepTime: true) }
            } else {
                observers.values.forEach{ $0.musicPlayer?(player: self, sleepTimeChanged: interval) }
            }
        }
        
        updateCommandCenterInfo()
    }
}

// MARK: - Private
private extension MusicPlayer {
    
    private func toggleNext() {
        if setting.isShuffled && tracks.count > 1 {
            var nextIndex = index ?? 0
            repeat {
                nextIndex = Int(arc4random_uniform(UInt32(tracks.count)))
            } while nextIndex == index
        } else {
            forward()
        }
    }
    
    private func load(track: Track, and play: Bool = true) {
        
        if let index = tracks.firstIndex(of: track) {
            observers.values.forEach{ $0.musicPlayer?(player: self, Loading: track, at: index) }
        }
        
        MusicManager.shared.music.fetchPlayableURL(track: track) { (error, url) in
            
            if let index = self.tracks.firstIndex(of: track) {
                self.observers.values.forEach{ $0.musicPlayer?(player: self, didLoad: track, at: index) }
            }
            
            if self.track?.id != track.id { return }
            
            if let error = error {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.forward()
                })
                return
            }
            
            if let url = url {
                let playerItem = AVPlayerItem(url: url)
                self.player.currentItem?.asset.cancelLoading()
                self.player = AVPlayer(playerItem: playerItem)
                self.playerLayer.player = self.player
                self.player.play()
                self.setting.isPlaying = true
                
                if let index = self.index {
                    self.observers.values.forEach{ $0.musicPlayer?(player: self, startPlaying: track, at: index) }
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    public func updateCommandCenterInfo() {
        guard let track = track else { return }
        
        let time = CMTimeGetSeconds(player.currentTime())
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.name,
            MPMediaItemPropertyPlaybackDuration: player.currentItem?.duration.seconds,
            MPNowPlayingInfoPropertyPlaybackRate: setting.isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: time
        ]
        
        if let link = track.coverURL {
            SDWebImageManager.shared().loadImage(with: URL(string: link), options: [], progress: nil) { (image, _, _, _, _, _) in
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image!)
                MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            }
        } else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
}

// MARK: - UI
public extension MusicPlayer {
    
    public func registSlider(slider: UISlider) {
        let id = ObjectIdentifier(slider)
        progressView[id] = slider
        
        slider.addTarget(self, action: #selector(progressValueDidChanged(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(progressDidEndChanged(slider:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(progressDidEndChanged(slider:)), for: .touchUpOutside)
    }
    
    public func removeSlider(slider: UISlider) {
        let id = ObjectIdentifier(slider)
        observers.removeValue(forKey: id)
        
        slider.removeTarget(self, action: #selector(progressDidEndChanged(slider:)), for: .valueChanged)
        slider.removeTarget(self, action: #selector(progressDidEndChanged(slider:)), for: .touchUpInside)
        slider.removeTarget(self, action: #selector(progressDidEndChanged(slider:)), for: .touchUpOutside)
    }
}

// MARK: - Observer
public extension MusicPlayer {
    
    public func registObserver(_ observer: MusicPlayerObserver) {
        let id = ObjectIdentifier(observer)
        observers[id] = observer
    }
    
    public func removeObserver(_ observer: MusicPlayerObserver) {
        let id = ObjectIdentifier(observer)
        observers.removeValue(forKey: id)
    }
}

// MARK: - Util
private extension MusicPlayer {
    
    private var randomIndex: Int {
        get {
            return Int(arc4random_uniform(UInt32(tracks.count)))
        }
    }
}

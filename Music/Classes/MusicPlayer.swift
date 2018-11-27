//
//  MusicPlayer.swift
//  Alamofire
//
//  Created by lcf on 2018/11/27.
//

import UIKit
import AVFoundation
import MediaPlayer

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
    
    private var track: Track?
    private var index: Int?
    
    public override init() {
        super.init()
        playerLayer.player = player
        playerLayer.backgroundColor = UIColor.black.cgColor
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
        
        for observer in observers.values {
            observer.musicPlayer?(player: self, didSet: tracks)
        }
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
}

// MARK: - Player
public extension MusicPlayer {
    
    func play() {
        if track == nil {
            
        }
    }
    
    func pause() {
        
    }
    
    func forward() {
        
    }
    
    func backward() {
        
    }
    
    func seek(to time: Double) {
        
    }

    func seekForward() {
        
    }
    
    func seekBackward() {
        
    }
}

// MARK: - Private
private extension MusicPlayer {
    
    private func playNext() {
        
    }
}

// MARK: - Action
public extension MusicPlayer {
    
    @objc func progressValueDidChanged(slider: UISlider) {
        
    }
    
    @objc func progressDidEndChanged(slider: UISlider) {
        
    }
    
    @objc func timerHandler() {
        
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

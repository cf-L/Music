//
//  MusicPlayer+Notification.swift
//  Alamofire
//
//  Created by lcf on 2018/11/28.
//

import UIKit
import AVFoundation

public extension MusicPlayer {
    
    public func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime(notification:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemPlaybackStalled(notification:)),
            name: NSNotification.Name.AVPlayerItemPlaybackStalled,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionInterruption(notification:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(volumeDidChange(notification:)),
            name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(apppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc func playerItemDidPlayToEndTime(notification: Notification) {
        self.playNext()
    }
    
    @objc func playerItemPlaybackStalled(notification: Notification) {
        guard let track = track, let index = index else { return }
        observers.values.forEach{ $0.musicPlayer?(player: self, buffering: track, at: index) }
    }
    
    @objc func audioSessionInterruption(notification: Notification) {
        pause()
    }
    
    @objc func appDidEnterBackground() {
        playerLayer.player = nil
    }
    
    @objc func apppWillEnterForeground() {
        playerLayer.player = player
    }
    
    @objc func volumeDidChange(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let volume = AVAudioSession.sharedInstance().outputVolume
            self.observers.values.forEach{ $0.musicPlayer?(player: self, volumnChanged: volume) }
        }
    }
}

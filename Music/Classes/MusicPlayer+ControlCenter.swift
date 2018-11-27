//
//  MusicPlayer+ControlCenter.swift
//  Alamofire
//
//  Created by lcf on 2018/11/27.
//

import UIKit
import AVFoundation
import MediaPlayer

public extension MusicPlayer {
    
    public func registBackgroundMode() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        configControlCenter()
    }
    
    private func configControlCenter() {
        guard #available(iOS 9.1, *) else { return }
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.seek(to: event.positionTime)
            }
            return MPRemoteCommandHandlerStatus.success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(handler: { (event) -> MPRemoteCommandHandlerStatus in
            self.forward()
            return .success
        })
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(handler: { (event) -> MPRemoteCommandHandlerStatus in
            self.play()
            return .success
        })
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(handler: { (event) -> MPRemoteCommandHandlerStatus in
            self.pause()
            return .success
        })
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(handler: { (event) -> MPRemoteCommandHandlerStatus in
            self.backward()
            return .success
        })
    }
    
    public func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else { return }
        
        switch event.subtype {
        case .remoteControlNextTrack:
            forward()
        case .remoteControlPreviousTrack:
            backward()
        case .remoteControlPlay:
            play()
        case .remoteControlPause:
            pause()
        case .remoteControlTogglePlayPause:
            setting.isPlaying ? pause() : play()
        case .remoteControlBeginSeekingForward:
            break
        case .remoteControlEndSeekingForward:
            seekForward()
        case .remoteControlBeginSeekingBackward:
            break
        case .remoteControlEndSeekingBackward:
            seekBackward()
        default:
            break
        }
    }
}

//
//  MusicPlayer+Setting.swift
//  Alamofire
//
//  Created by lcf on 2018/11/27.
//

import UIKit
import MediaPlayer

// MARK: - Setting
public extension MusicPlayer {
    
    public class Setting: NSObject {
        public var isShuffled: Bool = false
        public var isPlaying: Bool = false
        public var stopDate: Date?
        public var loopMode: LoopMode = .listLoop
        
        private var volumeView = MPVolumeView()
        
        public var volume: Float {
            get {
                if let slider = volumeView.subviews.filter({ NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}).first as? UISlider {
                    return slider.value
                }
                return 0.0
            }
            set {
                if let slider = volumeView.subviews.filter({ NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}).first as? UISlider {
                    slider.value = newValue
                }
            }
        }
    }
    
    public enum LoopMode: Int {
        case listLoop
        case single
        case list
        
        public var next: LoopMode {
            get {
                switch self {
                case .list:
                    return .listLoop
                case .listLoop:
                    return .single
                case .single:
                    return .list
                }
            }
        }
    }
}

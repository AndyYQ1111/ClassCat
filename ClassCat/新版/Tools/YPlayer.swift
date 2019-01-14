//
//  YPlayer.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/19.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit
import AVFoundation

enum STATUS {
    case PLAYING
    case PAUSE
}

class YPlayer: NSObject {
    
    var player:AVPlayer?
    
    var status:STATUS = .PAUSE
    
    var currentUrlStr:String?
    
    static let shared = YPlayer()
    
    override init() {
        player = AVPlayer()
    }
    
    func setUrl(urlStr:String) {
        currentUrlStr = urlStr
        if((player?.currentItem) != nil){
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            player?.currentItem?.removeObserver(self, forKeyPath: "status")
        }
        
        let url = URL(string: urlStr)
        let item = AVPlayerItem(url: url!)
        player?.replaceCurrentItem(with: item)
        if((player?.currentItem) != nil){
            NotificationCenter.default.addObserver(self, selector: #selector(finish(noti:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        }
    }
    @objc func finish(noti:Notification) {
        print("播放完成")
        status = .PAUSE
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "status") {
            if (player!.currentItem!.status == .readyToPlay) {
                print("开始播放")
                player?.play()
                status = .PLAYING
            }
        }
    }
}

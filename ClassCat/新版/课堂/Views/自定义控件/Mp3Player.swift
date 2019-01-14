//
//  MusicPlayer.swift
//  IntelligentBox
//
//  Created by YueAndy on 2018/12/11.
//  Copyright © 2018年 Zhuhia Jieli Technology. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

typealias PlayBlock = () -> (Void)

@IBDesignable
class Mp3Player: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var btn_play: UIButton!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var lab_max: UILabel!
    
    @IBOutlet weak var lab_min: UILabel!
    
    
    
    var playBlock:PlayBlock?
    
    var playerItem:AVPlayerItem?
    
    let player:AVPlayer = YPlayer.shared.player!
    
    var musicUrl:URL?
    var musicUrlStr:String?
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable
    var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialFromXib()
        initPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialFromXib()
        initPlayer()
    }
    
    func initialFromXib() {
        let nib = UINib(nibName: "Mp3Player", bundle: Bundle.main)
        contentView = (nib.instantiate(withOwner: self, options: nil).first as! UIView)
        contentView.frame = bounds
        addSubview(contentView)
        slider.setThumbImage(UIImage(named: "icon_point"), for: .normal)
        slider.setThumbImage(UIImage(named: "icon_point"), for: .highlighted)
    }
    
    func initPlayer(){
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { (time) in
            if(self.musicUrlStr == YPlayer.shared.currentUrlStr){
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                self.slider.value = Float(currentTime)
                
                let all:Int = Int(currentTime)
                let m:Int = all % 60
                let f:Int = Int(all/60)
                var time:String = ""
                if(f<10){
                    time = "0\(f):"
                }else{
                    time = "\(f):"
                }
                
                if(m<10){
                    time += "0\(m)"
                }else{
                    time += "\(m)"
                }
                self.lab_min.text = time
            }else{
                self.slider.value = 0
                self.btn_play.isSelected = false
                self.lab_min.text = "00:00"
            }
        })
    }
    
    func setMusicUrl(urlStr:String){
        musicUrlStr = urlStr
        if(urlStr.hasPrefix("http:")){
            musicUrl = URL(string: urlStr)
        }else{
            musicUrl = URL(fileURLWithPath: urlStr)
        }
    
        DispatchQueue.global().async {
            self.playerItem = AVPlayerItem(url: self.musicUrl!)
            NotificationCenter.default.addObserver(self, selector: #selector(self.finish(noti:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            //处理耗时操作的代码块...
            let duration:CMTime = (self.playerItem?.asset.duration)!
        
            let seconds:Float = Float(CMTimeGetSeconds(duration))

            let all:Int = Int(seconds)
            let m:Int = all % 60
            let f:Int = Int(all/60)
            var time:String = ""
            if(f<10){
                time = "0\(f):"
            }else{
                time = "\(f):"
            }

            if(m<10){
                time += "0\(m)"
            }else{
                time += "\(m)"
            }
            //操作完成，调用主线程来刷新界面
            DispatchQueue.main.async {
                self.slider.maximumValue = seconds
                self.lab_max.text = time
            }
        }
    }
    
    @objc func finish(noti:Notification)  {
        print("播放结束")
        DFAudioPlayer.didPauseLast()
        let stopedPlayerItem:AVPlayerItem = noti.object as! AVPlayerItem
        stopedPlayerItem.seek(to: CMTime.zero)
        btn_play.isSelected = false
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if(player.rate == 0){
            YPlayer.shared.currentUrlStr = musicUrlStr
            player.replaceCurrentItem(with: self.playerItem)
            player.play()
            self.playBlock!()
        }else{
            player.pause()
        }
    }
    
    @IBAction func valueChange(_ sender: UISlider) {
        let seconds:Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
        if(player.rate == 0){
            player.play()
            btn_play.isSelected = true
        }
    }
}

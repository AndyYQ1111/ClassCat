//
//  RecordManager.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/14.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class RecordManager {
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    let file_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/record.caf")
    let mp3path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/record.mp3")
    init() {
        let session = AVAudioSession.sharedInstance()
        //设置session类型
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
        }
        //设置session动作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
        }
        //开始录音
        do {
            let url = URL(fileURLWithPath: file_path!)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting())
            recorder!.prepareToRecord()
            print("开始录音")
        } catch let err {
            print("录音失败:\(err.localizedDescription)")
        }
    }
    //开始录音
    func beginRecord() {
        recorder!.record()
    }

    //结束录音
    func stopRecord() {
        if let recorder = self.recorder {
            if recorder.isRecording {
                print("正在录音，马上结束它，文件保存到了：\(file_path!)")
            }else {
                print("没有录音，但是依然结束它")
            }
            recorder.stop()
            YqsPcm2Mp3.sharedInstacn()?.convert(withPcmPath: file_path, mp3Path: mp3path)
        }else {
            print("没有初始化")
        }
    }
    //MARK: 暂停
    func puaseRecord() {
        if((self.recorder?.isRecording)!){
            self.recorder?.pause()
        }
    }

    //MARK: 继续
    func resumeRecord() {
        beginRecord()
    }

    //MARK: 播放
    func play() {
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: mp3path!))
            print("歌曲长度：\(player!.duration)")
            player!.play()
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
    }
    
    func recordSetting() -> Dictionary<String, Any> {
        //录音设置，注意，后面需要转换成NSNumber，如果不转换，你会发现，无法录制音频文件，我猜测是因为底层还是用OC写的原因
        let recordSetting: [String: Any] = [AVSampleRateKey: NSNumber(value: 11025.0),//采样率
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),//音频格式
            AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
            AVNumberOfChannelsKey: NSNumber(value: 2),//通道数
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)//录音质量
        ]
        return recordSetting
    }
}

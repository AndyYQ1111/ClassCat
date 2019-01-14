//
//  RecordVC.swift
//  IntelligentBox
//
//  Created by YueAndy on 2018/12/11.
//  Copyright © 2018年 Zhuhia Jieli Technology. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class RecordVC: BaseViewController {
    
    let mp3path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/record.mp3")
    
    var isDevRecord:Bool?
    
    @IBOutlet weak var lab_time: UILabel!
    @IBOutlet weak var btn_record: UIButton!
    @IBOutlet weak var btn_restart: UIButton!
    @IBOutlet weak var btn_done: UIButton!
    
    
    typealias Doneblock = (_ recordPath:String)->()
    var backBlock: Doneblock?
    
    var recoder_manager:RecordManager?
    
    var timer = Timer()
    
    var time:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recoder_manager = RecordManager()//初始化
        DFNotice.add(kJL_RECORD_PATH, action: #selector(noteRecordPath(note:)), own: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(isDevRecord == true){
            btn_restart.isEnabled = false
            btn_done.isEnabled = false
            btn_record.isSelected = true
            btn_record.isEnabled = false
            timer.fire()
            timer.fireDate = Date.distantPast
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DFNotice.remove(kJL_RECORD_PATH, own: self)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true) {}
    }
    
    //MARK: 暂停或继续
    @IBAction func recordAction(_ sender: UIButton) {
        btn_restart.isEnabled = true
        btn_done.isEnabled = true
        sender.isSelected = !sender.isSelected
        if(sender.isSelected){
            recoder_manager?.beginRecord()//开始录音
            timer.fire()
            timer.fireDate = Date.distantPast
        }else{
            recoder_manager?.puaseRecord()
            timer.fireDate = Date.distantFuture
            time -= 1
        }
    }
    //MARK:录制完成
    @IBAction func doneAction(_ sender: UIButton) {
        recoder_manager?.stopRecord()
        btn_record.isSelected = false;
        recoder_manager?.play()
        timer.fireDate = Date.distantFuture
        self.backBlock!(recoder_manager!.file_path!)
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: 重新开始录制
    @IBAction func restartAction(_ sender: UIButton) {
        recoder_manager?.stopRecord()
        recoder_manager?.beginRecord()//开始录音
        btn_record.isSelected = true;
        time = -1
        timer.fireDate = Date.distantPast
    }
    
    @objc func noteRecordPath(note:Notification){
        timer.fireDate = Date.distantFuture
        time -= 1
        let jl_Listen:JL_Listen =  JL_Listen.sharedMe() as! JL_Listen
        YqsPcm2Mp3.sharedInstacn()?.convert(withPcmPath: jl_Listen.pcmPath, mp3Path: mp3path)
        self.backBlock!(mp3path!)
        self.dismiss(animated: true, completion: nil)
    }
}

extension RecordVC{
    override func setupUI() {
        self.modalPresentationStyle = .custom
        timer = Timer.scheduledTimer(timeInterval: 1,target:self,selector:#selector(tickDown),userInfo:nil,repeats:true)
        timer.fireDate = Date.distantFuture
        btn_restart.imgUp()
        btn_done.imgUp()
    }
    @objc func tickDown() {
        time += 1
        let minute = NSNumber(value: time / 60)
        let second = NSNumber(value: time % 60)
        let numberFormatter  = NumberFormatter()
        //设置number显示样式
        numberFormatter.numberStyle = .none //四舍五入的整数
        numberFormatter.formatWidth = 2 //补齐10位
        numberFormatter.paddingCharacter = "0" //不足位数用0补
        numberFormatter.paddingPosition = .beforePrefix  //补在前面
        //格式化
        let minuteStr = numberFormatter.string(from: minute)!
        let secondStr = numberFormatter.string(from: second)!
        lab_time.text = minuteStr + ":" + secondStr
    }
}

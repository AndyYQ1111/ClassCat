//
//  ModifyPWVC.swift
//  IntelligentBox
//
//  Created by YueAndy on 2018/12/10.
//  Copyright © 2018年 Zhuhia Jieli Technology. All rights reserved.
//

import UIKit

class ModifyPWVC: BaseViewController {

    @IBOutlet weak var tf_code: UITextField!
    @IBOutlet weak var tf_pw1: UITextField!
    @IBOutlet weak var tf_pw2: UITextField!
    @IBOutlet weak var btn_besure: UIButton!
    @IBOutlet weak var btn_code: UIButton!
    
    var timeStamp:String?
    
    let userId:String? = (UserDefaults.standard.value(forKey: "userId") as? String)
    
    //MARK: 获取验证码倒计时
    var countdownTimer: Timer?
    //代表当前倒计时剩余的秒数
    var remainingSeconds:Int = 0 {
        willSet {
            btn_code.setTitle("\(newValue)秒", for: .normal)
            if newValue <= 0 {
                btn_code.setTitle("重新获取", for: .normal)
                isCounting = false
            }
        }
    }
    var isCounting:Bool = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime(timer:)), userInfo: nil, repeats: true)
                remainingSeconds = 60
            }else {
                countdownTimer?.invalidate()
                countdownTimer = nil
            }
            btn_code.isEnabled = !newValue
        }
    }
    @objc func updateTime(timer: Timer) {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.navigationBar.isHidden = false
    }
    
    
    // MARK: -获取验证码
    @IBAction func getCodeAction(_ sender: UIButton) {
        // 启动倒计时
        isCounting = true
        
        tf_code.becomeFirstResponder()
        
        timeStamp = getNowTimeStamp()
        
        let paraDic:[String:Any] = ["userPhoneNum" : userId ?? "","timeStamp" : timeStamp!]
        NetWorkTools.requestData(method: .POST, urlString: "smsService/smsService.php?act=sendSmsIdCode", paraDic: paraDic) { (json) in
            let dic = json as! [String:Any]
            let result:String = dic["result"] as! String
            if(result == "ok"){
                self.view.makeToast("验证码已发送", duration: 2.0, position: .center)
            }else{
                self.view.makeToast("验证码已失败，请重试", duration: 2.0, position: .center)
            }
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        if(tf_code.text?.count==0 || tf_pw1.text?.count==0||tf_pw2.text?.count==0){
            self.view.makeToast("请先完善信息", duration: 2.0, position: .center)
        }else if(tf_pw2.text != tf_pw1.text){
            self.view.makeToast("两密码不一致", duration: 2.0, position: .center)
        }else{
            let paraDic:[String:Any] = ["userPhone" : userId ?? "","smsCode" : tf_code.text ?? "","timeStamp":timeStamp!,"password":tf_pw1.text ?? ""]
            NetWorkTools.requestData(method: .POST, urlString: "user.php?act=resetUserPwd", paraDic: paraDic) { (json) in
                let dic = json as! [String:Any]
                let result:String = dic["result"] as! String
                if(result == "ok"){
                    self.view.makeToast("修改成功")
                    UserDefaults.standard.set(self.tf_pw1.text!, forKey: "password")
                }else if(result == "userNotExist"){
                    self.view.makeToast("用户不存在")
                }else if(result == "smsCodeError"){
                    self.view.makeToast("验证码出错")
                }
            }
        }
    }
}

extension ModifyPWVC{
    override func setupUI()  {
        tfSytle()
        title = "修改密码"
        btn_besure.layer.cornerRadius = 22
    }
    
    func tfSytle() {
        
        tf_code.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
        tf_pw1.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
        tf_pw2.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
    }
}

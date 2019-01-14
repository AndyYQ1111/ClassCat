//
//  RegisterVC.swift
//  IntelligentBox
//
//  Created by YueAndy on 2018/12/6.
//  Copyright © 2018年 Zhuhia Jieli Technology. All rights reserved.
//

import UIKit

class RegisterVC: BaseViewController {
    
    @IBOutlet weak var tf_phonenum: UITextField!
    @IBOutlet weak var tf_code: UITextField!
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var tf_pw: UITextField!
    @IBOutlet weak var btn_reg: UIButton!
    @IBOutlet weak var btn_icon: UIButton!
    @IBOutlet weak var btn_code: UIButton!
    
    var editTF:UITextField?
    //键盘启点Y
    var keyboardY:CGFloat = 0
    //键盘出现动画需要的时间
    var duration:Double = 0
    
    var iconModel:IconModel?
    
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
        super.viewWillAppear(false)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        releaseNotification()
    }
    
   
    
    // MARK: -上传头像
    @IBAction func upIcon(_ sender: UIButton) {
        let pc = PhotoCenter.shared
        pc.chooseImg()
        pc.finishCallBack = {(image) -> () in
            image.jpegData(compressionQuality: 0.5)
            sender.setImage(image, for: .normal)
            NetWorkTools.upload(urlString: "user.php?act=uploadUserHeadImage", params: nil, images: [image], success: { (result) in
                let jsonDecoder = JSONDecoder()
                let jsonData = try? JSONSerialization.data(withJSONObject: result as Any, options: [])
                self.iconModel = try! jsonDecoder.decode(IconModel.self, from: jsonData!)

            }, failture: { (err) in
                print(err.localizedDescription)
            })
        }
    }
    // MARK: -显示密码
    @IBAction func showPW(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        tf_pw.isSecureTextEntry = !sender.isSelected
    }
    // MARK: -获取验证码
    @IBAction func getCodeAction(_ sender: UIButton) {
        // 启动倒计时
        isCounting = true
    
        tf_code.becomeFirstResponder()
        
        let timeStamp = getNowTimeStamp()
        
        if(tf_phonenum.text?.count == 0){
            self.view.makeToast("请输入电话号码", duration: 3.0, position: .center)
        }else{
            let paraDic:[String:Any] = ["userPhoneNum" : tf_phonenum.text ?? "","timeStamp" : timeStamp]
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
    }
    @IBAction func regAction(_ sender: UIButton) {
        if(tf_phonenum.text?.count == 0 || tf_name.text?.count == 0 || tf_pw.text?.count == 0 || tf_code.text?.count == 0){
            self.view.makeToast("请先完善信息", duration: 2.0, position: .center)
        }else{
            let paraDic:[String:String] = ["userId" : tf_phonenum.text!,"userName" : tf_name.text!,"password":tf_pw.text!,"headImage":iconModel?.headImgUrl ?? "","smsCode":tf_code.text!]
            NetWorkTools.requestData(method: .POST, urlString: "user.php?act=register", paraDic: paraDic) { (json) in
               
                let dic = json as! [String:Any]
                let result:String = dic["result"] as! String
                
                if(result == "userExist"){
                    self.view.makeToast("用户已存在", duration: 2.0, position: .center)
                }else if(result == "smsCodeError"){
                    self.view.makeToast("短信验证错误", duration: 2.0, position: .center)
                }else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension RegisterVC {
    @objc override func setupUI() {
        self.tfSytle()
        btn_reg.layer.cornerRadius = 22
        btn_icon.layer.cornerRadius = 46
        btn_icon.layer.masksToBounds = true
        self.title = "注册"
        registerNotification()
    }
    
    func tfSytle() {
        tf_phonenum.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
        tf_code.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
        tf_name.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
        tf_pw.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
    }
    
    //MARK:监听键盘通知
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(node:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //MARK:键盘通知相关操作
    @objc func keyBoardWillShow(node:Notification){
        //1.获取动画执行的时间
        duration =  node.userInfo!["UIKeyboardAnimationDurationUserInfoKey"] as! Double
        //2. 获取键盘最终的Y值
        let endFrame = (node.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! NSValue).cgRectValue
        keyboardY = endFrame.origin.y

        let win = UIApplication.shared.keyWindow
        
        let rect = editTF?.convert((editTF?.bounds)!, to: win)
        //正在编辑的控件的位置
        let y2 = (rect?.origin.y)! + (rect?.size.height)!
    
        UIView.animate(withDuration: duration) {
            if(self.keyboardY >= y2) {
                self.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }else{
                self.view.transform = CGAffineTransform(translationX: 0, y: self.keyboardY-y2-10)
            }
        }
    }

    //MARK:释放键盘监听通知
    func releaseNotification(){
        NotificationCenter.default.removeObserver(self)
    }
}

extension RegisterVC:UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) // became first responder
    {
        editTF = textField
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}

//
//  LoginVC.swift
//  IntelligentBox
//
//  Created by YueAndy on 2018/12/6.
//  Copyright © 2018年 Zhuhia Jieli Technology. All rights reserved.
//

import UIKit

class LoginVC: BaseViewController {
    @IBOutlet weak var tf_pw: UITextField!
    @IBOutlet weak var tf_acount: UITextField!
    @IBOutlet weak var btn_login: UIButton!
    
    //type == logout b退出登录
    var type:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    @IBAction func showPW(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        tf_pw.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func regAction(_ sender: UIButton) {
        self.navigationController?.pushViewController(RegisterVC(), animated: true)
    }
    @IBAction func forgetPWAction(_ sender: UIButton) {
        self.navigationController?.pushViewController(ForgetPWVC(), animated: true)
    }
    @IBAction func loginAction(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if(tf_acount.text?.count == 0 || tf_pw.text?.count == 0 ){
            self.view.makeToast("请先完善信息", duration: 2.0, position: .center)
        }else{
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
            
            let paraDic:[String:String] = ["userId" : tf_acount.text!,"password":tf_pw.text!,"APPVersion":appVersion as! String,"PhoneOSType":"ios"]
            NetWorkTools.requestData(method: .POST, urlString: "user.php?act=login", paraDic: paraDic) { (json) in
                
                let jsonDecoder = JSONDecoder()
                let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
                let loginInfo:LoginInfo = try! jsonDecoder.decode(LoginInfo.self, from: jsonData!)
                
                
                if(loginInfo.result == "userNotExist"){
                    self.view.makeToast("用户不存在", duration: 2.0, position: .center)
                }else if(loginInfo.result == "passwordError"){
                    self.view.makeToast("密码错误", duration: 2.0, position: .center)
                }else if(loginInfo.result == "ok"){
                    UserDefaults.standard.set(true, forKey: "isLogin")//已经登录了
                    UserDefaults.standard.set(self.tf_acount.text!, forKey: "userId")
                    UserDefaults.standard.set(self.tf_pw.text!, forKey: "password")
                    UserDefaults.standard.set(loginInfo.mediaServerUrlL, forKey: "mediaServerUrl")
                    UserDefaults.standard.set(loginInfo.defaultCourseId, forKey: "defaultCourseId")
                    UserDefaults.standard.set(loginInfo.interServerUrl, forKey: "interServerUrl")
                    UserDefaults.standard.set(loginInfo.userInfo.headImage, forKey: "headImage")
                    UserDefaults.standard.set(loginInfo.userInfo.country, forKey: "country")
                    UserDefaults.standard.set(loginInfo.userInfo.province, forKey: "province")
                    UserDefaults.standard.set(loginInfo.userInfo.city, forKey: "city")
                    UserDefaults.standard.set(loginInfo.userInfo.sex, forKey: "sex")
                    UserDefaults.standard.set(loginInfo.userInfo.name, forKey: "name")
                    
                    UserDefaults.standard.synchronize()
                    self.navigationController?.dismiss(animated: true, completion: {
                    })
                }
                let alertC = UIAlertController(title: "检测到更新", message: loginInfo.updateContent, preferredStyle: .alert)
                let sureAction = UIAlertAction(title: "更新", style: .default, handler: { (action) in
                    let appStoreUrl = URL(string:"https://itunes.apple.com/us/app/%E7%B4%A2%E7%88%B1ai%E9%9F%B3%E7%AE%B1/id1435570520?l=zh&ls=1&mt=8")
                    UIApplication.shared.open(appStoreUrl!, options: [:], completionHandler: nil)
                })
                alertC.addAction(sureAction)
                if("1" == loginInfo.versionResult ){
                    self.present(alertC, animated: true, completion: nil)
                }else if("2" == loginInfo.versionResult){
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    alertC.addAction(cancelAction)
                    self.present(alertC, animated: true, completion: nil)
                }
            }
        }
    }
}


extension LoginVC{
    override func setupUI()  {
        tfSytle()
        title = "登录"
        btn_login.layer.cornerRadius = 22
        
        let userId:String? = UserDefaults.standard.object(forKey: "userId") as? String
        tf_acount.text = userId
    }
    
    func tfSytle() {
        tf_acount.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
        tf_pw.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
    }
}

extension LoginVC: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}

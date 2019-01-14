//
//  ProfileVC.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/17.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit

class ProfileVC: BaseViewController {
    
    @IBOutlet weak var v_info: UIView!
    @IBOutlet weak var icon_profile: UIImageView!
    @IBOutlet weak var img_circle: UIImageView!
    @IBOutlet weak var img_bg: UIImageView!
    @IBOutlet weak var t_mine: UITableView!
    @IBOutlet weak var lab_name: UILabel!
    
    let cellId = "ProfileCell"
    var imgs_titles:[[String]?]?
    var lab_titles:[[String]?]?
    var vues:[String]?
    
    var headImg:String?
    let userId = UserDefaults.standard.object(forKey: "userId")
    var sex:String?
    var address:String?
    var province:String?
    var city:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        headImg = UserDefaults.standard.object(forKey: "headImage") as? String
        let imgUrl = URL(string: headImg ?? "")
        icon_profile.kf.setImage(with: imgUrl)
        img_bg.kf.setImage(with: imgUrl)
        let userName = UserDefaults.standard.object(forKey: "name") as? String
        lab_name.text = userName ?? ""
    }
    @IBAction func chaneNaneAction(_ sender: UIButton) {
        //初始化UITextField
        var inputText:UITextField = UITextField();
        let inputAlert = UIAlertController.init(title: "修改名称", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "确定", style:.default) { (action:UIAlertAction) ->() in
            if((inputText.text) == ""){
                print("你输入的是：\(String(describing: inputText.text))")
            }
        }
        let cancel = UIAlertAction.init(title: "取消", style:.cancel) { (action:UIAlertAction) -> ()in}
        
        inputAlert.addAction(ok)
        inputAlert.addAction(cancel)
        //添加textField输入框
        inputAlert.addTextField { (textField) in
            //设置传入的textField为初始化UITextField
            inputText = textField
            inputText.placeholder = "输入新名称"
        }
        inputText.text = lab_name.text
        self.present(inputAlert, animated: true, completion: nil)
    }
}
extension ProfileVC {
    override func setupUI() {
        v_info.layer.cornerRadius = 8
        v_info.layer.shadowOpacity = 1
        v_info.layer.shadowRadius = 5
        v_info.layer.shadowColor = UIColor.black.cgColor
        v_info.layer.shadowOffset = CGSize(width: 0, height: 0)
        v_info.layer.masksToBounds = false

        icon_profile.layer.cornerRadius = 40
        icon_profile.layer.masksToBounds = true
        img_circle.layer.cornerRadius = 54
        img_circle.layer.masksToBounds = true
        img_circle.layer.borderWidth = 7.5
        img_circle.layer.borderColor = UIColor.black.cgColor
        
        t_mine.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        lab_titles = [["账号","性别","地区"],["课堂信息","修改密码","使用帮助","退出登录"]]
        imgs_titles = [["icon_wode_zhanghao","icon_wode_xingbie","icon_wo_diqu"],["icon_wode_ketangxinxi","icon_wode_xiugaimima","icon_wode_shiyongbangzhu","icon_wode_tuichudenglu"]]
        sex = UserDefaults.standard.object(forKey: "sex") as? String
        sex = sex == "0" ? "男":"女"
        
//        let country:String = UserDefaults.standard.object(forKey: "country") as! String
        province = UserDefaults.standard.object(forKey: "province") as? String
        city = UserDefaults.standard.object(forKey: "city") as? String
    
        address = (province ?? "") + " " + (city ?? "")
        
        if(province?.count == 0){
            GetLocalization.sharedInstance()?.startUpdate({ (province, city) in
                self.province = province
                self.city = city
            })
        }
        vues = [userId, sex ?? "男",address] as? [String]
    }
}

extension ProfileVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lab_titles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lab_titles![section]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ProfileCell
        cell.lab_title.text = lab_titles![indexPath.section]![indexPath.row]
        cell.img_title.image = UIImage(named: imgs_titles![indexPath.section]![indexPath.row])
        if(indexPath.section == 1){
            cell.lab_vue.isHidden = true
        }else{
            cell.lab_vue.isHidden = false
            cell.lab_vue.text = vues![indexPath.row]
            if(indexPath.row == 0){
                cell.img_arrow.isHidden = true
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var v:UIView?
        v = UIView(frame: CGRect(x: 0, y: 0, width: kS_W, height: 15))
        v?.backgroundColor = UIColor(r: 239, g: 239, b: 244)
        return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 1){
            return 15
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as!ProfileCell
        switch indexPath.section {
        case 0:
            if(indexPath.row == 1){
                let alert = UIAlertController.init(title: "修改性别", message: nil, preferredStyle: .actionSheet)
                let male = UIAlertAction(title: "男", style: .default) { (action) in
                    
                    let paraDic:[String:String] = ["userId":self.userId as! String,"newSex":"0"]
                    
                    NetWorkTools.requestData(method: .POST, urlString: "user.php?act=changeUserSex", paraDic: paraDic) { (json) in
                        let dic = json as! [String:Any]
                        let result:String = dic["result"] as! String
                        if(result == "ok"){
                            self.view.makeToast("修改成功")
                            UserDefaults.standard.set("0", forKey: "sex")
                            cell.lab_vue.text = "男"
                        }else if(result == "notLoginYet"){
                            self.view.makeToast("用户还未登录")
                        }
                    }
                }
                let female = UIAlertAction(title: "女", style: .default) { (action) in
                    let paraDic:[String:String] = ["userId":self.userId as! String,"newSex":"1"]
                    NetWorkTools.requestData(method: .POST, urlString: "user.php?act=changeUserSex", paraDic: paraDic) { (json) in
                        let dic = json as! [String:Any]
                        let result:String = dic["result"] as! String
                        if(result == "ok"){
                            self.view.makeToast("修改成功")
                            UserDefaults.standard.set("1", forKey: "sex")
                            cell.lab_vue.text = "女"
                        }else if(result == "notLoginYet"){
                            self.view.makeToast("用户还未登录")
                        }
                    }
                }
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alert.addAction(male)
                alert.addAction(female)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }else if(indexPath.row == 2){
                let area = ([province,city] as! [String])
                BRAddressPickerView.showAddressPicker(withShowType: .city, defaultSelected: area, isAutoSelect: true, themeColor: UIColor.black, resultBlock: { (province, city, area) in
                    let paraDic:[String:String] = ["userId":self.userId as! String,"newCountry":"中国","newProvince":(province?.name)!,"newCity":(city?.name)!]
                    NetWorkTools.requestData(method: .POST, urlString: "user.php?act=changeUserRegion", paraDic: paraDic) { (json) in
                        let dic = json as! [String:Any]
                        let result:String = dic["result"] as! String
                        if(result == "ok"){
                            self.view.makeToast("修改成功")
                            UserDefaults.standard.set("1", forKey: "sex")
                            cell.lab_vue.text = (province?.name)! + " " + (city?.name)!
                            UserDefaults.standard.set("中国", forKey: "country")
                            UserDefaults.standard.set(province, forKey: "province")
                            UserDefaults.standard.set(city, forKey: "city")
                        }else if(result == "notLoginYet"){
                            self.view.makeToast("用户还未登录")
                        }
                    }
                }) {
                    print("取消")
                }
            }
           break
        case 1:
            if(indexPath.row == 0){
                self.navigationController?.pushViewController(LessonInfoVC(), animated: true)
            }else if(indexPath.row == 1){
                self.navigationController?.pushViewController(ModifyPWVC(), animated: true)
            }else if(indexPath.row == 2){
                print("使用帮助")
            }else if(indexPath.row == 3){
                print("退出登录")
                let nextVC = LoginVC()
                nextVC.type = "logout"
                let nav = BaseNavigationController.init(rootViewController: nextVC)
                self.present(nav, animated: true) {
                    UserDefaults.standard.removeObject(forKey: "password")
                }
            }
            break
        default:
            break
        }
    }
}

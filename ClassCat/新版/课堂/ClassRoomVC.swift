//
//  ClassRoomVC.swift
//  IntelligentBox
//
//  Created by YueAndy on 2018/12/10.
//  Copyright © 2018年 Zhuhia Jieli Technology. All rights reserved.
//

import UIKit

class ClassRoomVC: BaseViewController {
    
    @IBOutlet weak var sb_search: UISearchBar!
    
    @IBOutlet weak var t_course: UITableView!
    
    let classCellID = "ClassRoomCell"
    
    var userId:String?
    var password:String?
    
    
    var viewModles:[ViewModel]? = [ViewModel]()
    
    var bluetoothBtn:UIButton?
    
    var pageIndex:Int = 1
    
    var lisence:String?
    var cmd_ios:UInt32?
    var cmd_syst:UInt32?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JL_BLEUsage.sharedMe()
        JL_BDSpeechAI.sharedMe()
        JL_Listen.sharedMe()
        addNoti()
        userId = UserDefaults.standard.value(forKey: "userId") as? String
        password = UserDefaults.standard.value(forKey: "password") as? String
        
        if(userId==nil || password == nil){
            self.navigationController?.navigationBar.isHidden = false
            let nav = BaseNavigationController.init(rootViewController: IndexVC())
            self.present(nav, animated: true) {}
        }else{
            login()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { 
        super.viewWillAppear(animated)
        
        if(userId != nil){
            pageIndex = 1
            getKnowledges()
        }
    }
    
    func addNoti() {
        DFNotice.add(kBT_DEVICE_NOTIFY_SUCCEED, action: #selector(noteBTConnPaired(note:)), own: self)
        DFNotice.add(kCMD_MODE, action: #selector(noteModeInfo(note:)), own: self)
        DFNotice.add(kCMD_LISENCE, action: #selector(noteDeviceLisence(note:)), own: self)
        DFNotice.add(kCMD_SUC, action: #selector(noteCSW_SUC(note:)), own: self)
        
        DFNotice.add(kUI_DEVICE_DISCONNECT, action: #selector(noteBTDisconnectedPaired(note:)), own: self)
        DFNotice.add(kUI_DISCONNECTED, action: #selector(noteBTDisconnect(note:)), own: self)
    }
    
    @objc func noteBTConnPaired(note:Notification){
        self.bluetoothBtn?.isSelected = true;
        JL_BLE_Cmd.cmdModeInfo()
    }
    
    @objc func noteModeInfo(note:Notification){
        JL_BLE_Cmd.cmdDeviceLisence()
    }
    
    @objc func noteDeviceLisence(note: Notification) {
        cmd_ios = JL_BLE_Cmd.cmdPhoneiOS()
        let ls:NSData = note.object as! NSData
//        if(ls != nil){
            lisence = String.init(data: ls as Data, encoding: String.Encoding.utf8)
            ToolManager.saveDefauleData(lisence as Any, key: DEVICE_ID)
//        }
    }
    
    @objc func noteCSW_SUC(note:Notification){
        let tag:UInt32 = note.object as! UInt32
        if(tag == cmd_ios){
            let jl_Listen:JL_Listen = JL_Listen.sharedMe() as! JL_Listen
            if(jl_Listen.isCLOCK == true){
                cmd_syst = JL_BLE_Cmd.cmdSyncAlarmClock(Date())
            }else{
                let jl_BLE_Core:JL_BLE_Core = JL_BLE_Core.sharedMe() as! JL_BLE_Core
                jl_BLE_Core.keepCMD_90(true)
            }
        }
        if(tag == cmd_syst){
            let jl_BLE_Core:JL_BLE_Core = JL_BLE_Core.sharedMe() as! JL_BLE_Core
            jl_BLE_Core.keepCMD_90(true)
        }
    }
    
    //蓝牙被动断开
    @objc func noteBTDisconnectedPaired(note:Notification){
        self.bluetoothBtn?.isSelected = false;
        let jl_BLE_Core:JL_BLE_Core = JL_BLE_Core.sharedMe() as! JL_BLE_Core
        jl_BLE_Core.keepCMD_90(false)
        DFAction.delay(0.2) {
            DFAudioPlayer.didPauseLast()
        }
    }
    //蓝牙主动断开
    @objc func noteBTDisconnect(note:Notification){
        self.bluetoothBtn?.isSelected = false;
        let jl_BLE_Core:JL_BLE_Core = JL_BLE_Core.sharedMe() as! JL_BLE_Core
        jl_BLE_Core.keepCMD_90(false)
        DFAction.delay(0.2) {
            DFAudioPlayer.didPauseLast()
        }
    }
}

extension ClassRoomVC {
    override func setupUI() {
        title = "课堂"
        
        let vc = MusicFMViewController()
        vc.addNoti()
        
        addNavItem()
        t_course.register(UINib.init(nibName: classCellID, bundle: nil), forCellReuseIdentifier: classCellID)
        t_course.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.pageIndex = 1
            self.getKnowledges()
        })
            
        t_course.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            self.pageIndex += 1
            self.getKnowledges()
        })
    }
    //添加自定义导航栏
    func addNavItem() {
        let shareBtn = UIButton(title: "", imageName: "icon_ketang_fenxiang")
        shareBtn.frame = CGRect(x: 4, y: 0, width: 30, height: 30)
        shareBtn.addTarget(self, action: #selector(sharedClick), for: .touchUpInside)
        let shareItem = UIBarButtonItem(customView: shareBtn)
        let addBtn = UIButton(title: "", imageName: "icon_ketang_tianjia")
        addBtn.frame = CGRect(x: 4, y: 0, width: 30, height: 30)
        addBtn.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        let addItem = UIBarButtonItem(customView: addBtn)
        self.navigationItem.rightBarButtonItems = [addItem,shareItem]
        
        
        bluetoothBtn = UIButton(title: "", imageName: "icon_ketang_lanya_n")
        bluetoothBtn?.setImage(UIImage(named: "icon_ketang_lanya_s"), for: .selected)
        bluetoothBtn!.frame = CGRect(x: -4, y: 0, width: 30, height: 30)
        bluetoothBtn!.addTarget(self, action: #selector(bluetoothClick), for: .touchUpInside)
        let bluetoothItem = UIBarButtonItem(customView: bluetoothBtn!)
        self.navigationItem.leftBarButtonItem = bluetoothItem
    }
    
    @objc func rightItemClick() {
        self.navigationController?.pushViewController(AddPackageVC(), animated: true)
    }
    @objc func sharedClick() {
        let req = SendMessageToWXReq()
        req.bText = true
        req.text =  "分享内容"
        req.scene = Int32(WXSceneSession.rawValue)
        WXApi.send(req)
    }
    
    @objc func bluetoothClick() {
        print("蓝牙连接")
        let vc = BluetoothVC()
//        vc.block = { (num) in
//            print(num)
//            self.bluetoothBtn?.setImage(UIImage(named: "icon_ketang_lanya_s"), for: .normal)
//        }
//        print(vc.block)
        self.present(vc, animated: true, completion: nil)
    }
}

extension ClassRoomVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModles?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: classCellID, for: indexPath) as! ClassRoomCell
        cell.viewModel = viewModles![indexPath.row]
        cell.btn_more.tag = indexPath.row
        cell.btn_more.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let viewModle = viewModles![indexPath.row]
        return CGFloat(viewModle.contentHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @objc func moreAction(sender:UIButton) {
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "编辑", style: .default) { (UIAlertAction) in
            let nextVC = EidtPackageVC()
            nextVC.viewModel = self.viewModles![sender.tag]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        let delAction = UIAlertAction(title: "删除", style: .default) { (UIAlertAction) in
            let paraDic = ["userId":self.userId ?? "","knowledgeId": self.viewModles![sender.tag].knowledge!.knowledgeId!]
            let urlString = "knowledge.php?act=deleteKnowledge"
            
            NetWorkTools.requestData(method: .POST, urlString: urlString, paraDic: paraDic) { (json) in
                print(json)
                let jsonDecoder = JSONDecoder()
                let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
                let result:Result = try! jsonDecoder.decode(Result.self, from: jsonData!)
                if(result.result == "ok"){
                    self.view.makeToast("删除成功", duration: 1.0, position: .center)
                    self.viewModles?.remove(at: sender.tag)
                    self.t_course.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (UIAlertAction) in}
        
        alertC.addAction(editAction)
        alertC.addAction(delAction)
        alertC.addAction(cancelAction)
        
        self.present(alertC, animated: true) {
            
        }
    }
}
//MARK: 网络请求
extension ClassRoomVC{
    //MARK: 获取知识包
    func getKnowledges() {
        let courseId = UserDefaults.standard.object(forKey: "defaultCourseId") ?? ""
        let paraDic = ["userId":userId ?? "","courseId":courseId,"pageIndex":"\(pageIndex)","countPerPage":"20"]
        let urlString = "knowledge.php?act=getKnowledgeList"
        
        NetWorkTools.requestData(method: .POST, urlString: urlString, paraDic: paraDic) { (json) in
            self.t_course.mj_header.endRefreshing()
            self.t_course.mj_footer.endRefreshing()
            print(json)
            let jsonDecoder = JSONDecoder()
            let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
            let knowledges:Knowledges = try! jsonDecoder.decode(Knowledges.self, from: jsonData!)
            if(knowledges.result == "ok"){
                if(self.pageIndex == 1){
                    self.viewModles?.removeAll()
                }
                for knowledge in knowledges.data! {
                    let viewModel = ViewModel()
                    viewModel.knowledge = knowledge
                    self.viewModles?.append(viewModel)
                }
                self.t_course.reloadData()
            }
        }
    }
    
    func login()  {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        
        let paraDic:[String:String] = ["userId" : userId!,"password":password!,"APPVersion":appVersion as! String,"PhoneOSType":"ios"]
        NetWorkTools.requestData(method: .POST, urlString: "user.php?act=login", paraDic: paraDic) { (json) in
            
            let jsonDecoder = JSONDecoder()
            let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
            let loginInfo:LoginInfo = try! jsonDecoder.decode(LoginInfo.self, from: jsonData!)
            
            
            if(loginInfo.result == "userNotExist"){
                self.view.makeToast("用户不存在", duration: 2.0, position: .center)
            }else if(loginInfo.result == "passwordError"){
                self.view.makeToast("密码错误", duration: 2.0, position: .center)
            }else if(loginInfo.result == "ok"){
                self.getKnowledges()

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

extension ClassRoomVC:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.navigationController?.pushViewController(SearchViewController(), animated: true)
    }
}


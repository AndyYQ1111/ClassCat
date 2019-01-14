//
//  LessonInfoVC.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/20.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit

class LessonInfoVC: BaseViewController {
    
    let userId = UserDefaults.standard.value(forKey: "userId") as? String
    let courseId = UserDefaults.standard.object(forKey: "defaultCourseId") ?? ""
    @IBOutlet weak var tv_lession: UITableView!
    
    let kCellId = "LessionCell"
    
    var values = [[String]?]()
    var lab_titles:[[String]?]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension LessonInfoVC{
    override func setupUI() {
        title = "课堂信息"
        self.getInfoTask()
        tv_lession.register(UINib(nibName: kCellId, bundle: nil), forCellReuseIdentifier: kCellId)
        lab_titles = [["学校","课堂标题","课堂描述"],["已上传知识包","课堂被订阅数","知识包被阅读数","知识包被收藏数"]]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
}

extension LessonInfoVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return values.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath) as! LessionCell
        if(indexPath.section == 0){
           cell.imgv_arrow.isHidden = false
        }else{
            cell.imgv_arrow.isHidden = true
        }
        cell.lab_title.text = lab_titles?[indexPath.section]?[indexPath.row]
        cell.lab_vue.text = values[indexPath.section]?[indexPath.row]
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
        return 15
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            
            let urls = ["user.php?act=changeSchoolName","user.php?act=changeCourseTitle","user.php?act=changeCourseDescription"]
            let paraNames = ["newSchoolName","newCourseTitle","newCourseDescription"]
        
            //初始化UITextField
            var inputText:UITextField = UITextField();
            let inputAlert = UIAlertController.init(title: "修改\(lab_titles![indexPath.section]![indexPath.row])", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "确定", style:.default) { (action:UIAlertAction) ->() in
                if((inputText.text?.count)! > 0){
                    var paraDic:Dictionary = ["userId":self.userId ?? "","courseId":self.courseId as! String]
                    paraDic[paraNames[indexPath.row]] = inputText.text
                    
                    NetWorkTools.requestData(method: .POST, urlString: urls[indexPath.row], paraDic: paraDic) { (json) in
                        let dic = json as! [String:Any]
                        let result:String = dic["result"] as! String
                        if(result == "ok"){
                            self.view.makeToast("修改成功", duration: 1.0, position: .center)
                            self.values[indexPath.section]![indexPath.row] = inputText.text!
                            self.tv_lession.reloadData()
                        }else if(result == "notLoginYet"){
                            self.view.makeToast("用户还未登录", duration: 1.0, position: .center)
                        }
                    }
                }else{
                    self.view.makeToast("新\(paraNames[indexPath.row])不能为空", duration: 1.0, position: .center)
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
            self.present(inputAlert, animated: true, completion: nil)
        }
    }
}

extension LessonInfoVC{
    
    func getInfoTask() {
        let paraDic = ["userId":userId ?? "","courseId":courseId]
        let urlString = "user.php?act=getCourseBasicInfo"
        
        NetWorkTools.requestData(method: .POST, urlString: urlString, paraDic: paraDic) { (json) in
            print(json)
            let jsonDecoder = JSONDecoder()
            let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
            let course:Course = try! jsonDecoder.decode(Course.self, from: jsonData!)
            if(course.result == "ok"){
                var section0 = [String]()
                section0.append(course.schoolName!)
                section0.append(course.title!)
                section0.append(course.description!)
                var section1 = [String]()
                section1.append(course.knowledgeTotal!)
                section1.append(course.courseSubscribedTotal!)
                section1.append(course.knowledgeReadTotal!)
                section1.append(course.knowledgeCherishedTotal!)
                self.values.append(section0)
                self.values.append(section1)
                self.tv_lession.reloadData()
            }
        }
    }
}

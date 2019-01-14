//
//  AddPackageVC.swift
//  IntelligentBox
//
//  Created by YueAndy on 2018/12/10.
//  Copyright © 2018年 Zhuhia Jieli Technology. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer


class AddPackageVC: BaseViewController {
    
    @objc var isDevRecord:NSString?
    
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var tf_des: UITextField!
    @IBOutlet weak var cv_photo: UICollectionView!
    @IBOutlet weak var btn_record: UIButton!
    @IBOutlet weak var btn_upload: UIButton!
    @IBOutlet weak var btn_done: UIButton!
    @IBOutlet weak var v_mp3player: Mp3Player!
    @IBOutlet weak var btn_restart: UIButton!
    

    var filePath:String = ""
    
    let CellID = "PhotoCell"
    
    var imageCount : Int = 0
    
    var imageArray = Array<String>()
    
    var audioUrl:String = ""
    
    var lastImageId: Int32 = 0
    
    
    let userId = UserDefaults.standard.value(forKey: "userId") as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isDevRecord == "1"){
            self.recordAction(btn_record)
        }
    }
    
    //MARK: 录音
    @IBAction func recordAction(_ sender: UIButton) {
        self.v_mp3player.isHidden = true
        btn_restart.isHidden = true
        let nextVC = RecordVC()
        nextVC.backBlock = { (path) in
            self.filePath = path
            self.v_mp3player.setMusicUrl(urlStr: self.filePath)
            self.v_mp3player.isHidden = false
            self.btn_restart.isHidden = false
            var data:Data?
            do{
                try data = Data(contentsOf: URL(fileURLWithPath: path))
            }catch{
                print("没有数据")
            }
            
            let paraDic:[String : String]  = ["userId":self.userId!]
            let urlStr = "knowledge.php?act=uploadKnowledgeAudio"
            NetWorkTools.upload(urlString: urlStr, params: paraDic , data: data!, success: { (json) in
                print(json as Any)
                let jsonDecoder = JSONDecoder()
                let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
                let knowledgeAudio:KnowledgeAudio = try! jsonDecoder.decode(KnowledgeAudio.self, from: jsonData!)
                if(knowledgeAudio.result == "ok"){
                    self.view.makeToast("上传成功", duration: 1.0, position: .center)
                    self.audioUrl = knowledgeAudio.audioUrl!
                }
            }, failture: { (error) in
            
            })
        }
        nextVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        if(isDevRecord == "1"){
            nextVC.isDevRecord = true
        }
        self.present(nextVC, animated: true) {}
    }
    
    //MARK:重置
    @IBAction func resetAction(_ sender: UIButton) {
        v_mp3player.isHidden = true
        sender.isHidden = true
    }
    //MARK: 上传知识包
    @IBAction func doneAction(_ sender: UIButton) {
        if(tf_title.text?.count==0){
            self.view.makeToast("请填写标题", duration: 2.0, position: .center)
            return
        }
        
        if(tf_des.text?.count==0){
            self.view.makeToast("请填写描述信息", duration: 2.0, position: .center)
            return
        }

        

        let courseId = UserDefaults.standard.object(forKey: "defaultCourseId") ?? ""
        var images = [[String:String]]()
        for imgUrlStr in imageArray {
            let dic = ["imageUrl":imgUrlStr]
            images.append(dic)
        }
        
        let imagesStr = self.getJSONStringFromArray(array: images as NSArray)
        
        let paraDic = ["userId":userId ?? "","courseId":courseId,"title":tf_title.text!,"description":tf_des.text!,"audioUrl":audioUrl,"images":imagesStr]
        let urlString = "knowledge.php?act=createKnowledge"
        
        NetWorkTools.requestData(method: .POST, urlString: urlString, paraDic: paraDic) { (json) in
            let jsonDecoder = JSONDecoder()
            let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
            let result:Result = try! jsonDecoder.decode(Result.self, from: jsonData!)
            if(result.result == "ok"){
                self.view.makeToast("创建成功", duration: 1.0, position: .center)
            }
        }
    }
    func addNote() {
        DFNotice.add("record_start", action: #selector(noteSpeechStart(note:)), own: self)
    }
    
    
    @objc func noteSpeechStart(note:Notification) {
        self.resetAction(btn_record)
    }
    
}

extension AddPackageVC {
    override func setupUI() {
        title = "新增知识包"
        btn_done.layer.cornerRadius = 22
        btn_upload.layer.cornerRadius = 15
        btn_record.layer.cornerRadius = 15
        cv_photo.register(UINib.init(nibName: CellID, bundle: nil), forCellWithReuseIdentifier: CellID)
        v_mp3player.playBlock = {() in}
    }
    
    func getJSONStringFromArray(array:NSArray) -> String {
        
        if (!JSONSerialization.isValidJSONObject(array)) {
            print("无法解析出JSONString")
            return ""
        }
        
        let data : NSData! = try? JSONSerialization.data(withJSONObject: array, options: []) as NSData
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
}

extension AddPackageVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(imageArray.count<9){
            return imageArray.count + 1
        }else{
            return imageArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath) as! PhotoCell
        
        if(indexPath.row<9 && indexPath.row == imageArray.count){
            cell.iv_photo.image = UIImage(named: "icon_zhishibao_tianjia")
            cell.btn_del.isHidden = true;
        }else{
            let url = URL(string: imageArray[indexPath.row])
            cell.iv_photo.kf.setImage(with: url)
            cell.btn_del.isHidden = false;
        }
        cell.btn_del.tag = indexPath.row
        cell.btn_del.addTarget(self, action: #selector(delPhoto(sender:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        if(indexPath.row == self.imageArray.count && indexPath.row < 9){
            let pc = PhotoCenter.shared
            pc.chooseImg()
            pc.finishCallBack = {(image) -> () in
                image.jpegData(compressionQuality: 0.5)
                let paramDic:[String: String] = ["userId":self.userId!]
                NetWorkTools.upload(urlString: "knowledge.php?act=uploadKnowledgeImage", params: paramDic, images: [image], success: { (result) in
                    let jsonDecoder = JSONDecoder()
                    let jsonData = try? JSONSerialization.data(withJSONObject: result as Any, options: [])
                    let knowledgeImg:KnowledgeImg = try! jsonDecoder.decode(KnowledgeImg.self, from: jsonData!)
                    if(knowledgeImg.result == "ok"){
                        self.view.makeToast("上传成功", duration: 1.0, position: .center)
                        self.imageArray.append(knowledgeImg.imageUrl ?? "")
                        self.cv_photo.reloadData()
                    }
                }, failture: { (err) in
                    print(err.localizedDescription)
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 100, height: 100)
    }
    
    @objc func delPhoto(sender:UIButton) {
        view.endEditing(true)
        let tag = sender.tag
        self.imageArray.remove(at: tag)
        cv_photo.reloadData()
    }
}

extension AddPackageVC:MPMediaPickerControllerDelegate{
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true) {
        }
    }
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let item = mediaItemCollection.items.first
        
        print(item?.assetURL as Any)
        let url = item?.value(forProperty: MPMediaItemPropertyAssetURL)
        print(url as Any)
        self.dismiss(animated: true) {
        }
    }
}

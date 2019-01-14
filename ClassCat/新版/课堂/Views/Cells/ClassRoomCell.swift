//
//  ClassRoomCell.swift
//  IntelligentBox
//
//  Created by YueAndy on 2018/12/10.
//  Copyright © 2018年 Zhuhia Jieli Technology. All rights reserved.
//

import UIKit

class ClassRoomCell: BaseTableViewCell {
    @IBOutlet weak var lab_title: UILabel!
    @IBOutlet weak var lab_time: UILabel!
    @IBOutlet weak var lab_des: UILabel!
    @IBOutlet weak var lab_read: UILabel!
    @IBOutlet weak var lab_collect: UILabel!
    @IBOutlet weak var btn_more: UIButton!
    @IBOutlet weak var v_mp3player: Mp3Player!
    
    var _contentImageView:WBContentImageView?

    var viewModel:ViewModel? = nil {
        didSet{
            lab_title.text = viewModel!.knowledge?.knowledgeTitle
            lab_des.text = viewModel!.knowledge?.knowledgeDescription
            lab_time.text = self.updateTimeToCurrennTime(timeStamp: Double(viewModel!.knowledge!.createTime!)! * 1000)
            lab_read.text = (viewModel?.knowledge?.knowledgeReadTotal)! + " 阅读"
            lab_collect.text = (viewModel?.knowledge?.knowledgeCherishedTotal)! + " 收藏"
            
            if(viewModel!.contengImageHeight > 0){
                _contentImageView?.isHidden = false
            }else{
                _contentImageView?.isHidden = true
            }
            _contentImageView?.snp.updateConstraints({ (make) in
                make.height.equalTo((viewModel?.contengImageHeight)!)
            })
            
            let imgArr:NSMutableArray = NSMutableArray()
            for str in viewModel!.imgArr {
                imgArr.add(str)
            }
            _contentImageView?.urlArray = imgArr
            
            if(viewModel?.mp3Height == 30){
                v_mp3player.isHidden = false
                v_mp3player.setMusicUrl(urlStr: (viewModel?.knowledge?.knowledgeAudioUrl)!)
                _contentImageView?.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.lab_des.snp_bottomMargin).offset(50)
                })
            }else{
                v_mp3player.isHidden = true
                _contentImageView?.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.lab_des.snp_bottomMargin).offset(10)
                })
            }
            
            v_mp3player.playBlock = {() in
                let userId = UserDefaults.standard.object(forKey: "userId")
                let paraDic = ["userId":userId ?? "","knowledgeId": self.viewModel!.knowledge!.knowledgeId!]
                let urlString = "knowledge.php?act=readKnowledge"
                
                NetWorkTools.requestData(method: .POST, urlString: urlString, paraDic: paraDic) { (json) in
                    let jsonDecoder = JSONDecoder()
                    let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
                    let result:Result = try! jsonDecoder.decode(Result.self, from: jsonData!)
                    if(result.result == "ok"){
                        let readCount:Int = Int(self.viewModel!.knowledge!.knowledgeReadTotal!)! + 1
                        self.lab_read.text = "\(readCount) 阅读"
                    }
                }
            }
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        v_mp3player.layer.masksToBounds = true
        v_mp3player.layer.cornerRadius = 15
        v_mp3player.backgroundColor = UIColor.groupTableViewBackground
        
        _contentImageView = WBContentImageView()
        self.contentView.addSubview(_contentImageView!)
        _contentImageView?.snp.updateConstraints({ (make) in
            make.top.equalTo(self.lab_des.snp_bottomMargin).offset(10)
            make.right.left.equalTo(self.contentView).offset(0)
            make.height.equalTo(400)
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
    func updateTimeToCurrennTime(timeStamp: Double) -> String {
        //获取当前的时间戳
        let currentTime = Date().timeIntervalSince1970
        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        let timeSta:TimeInterval = TimeInterval(timeStamp / 1000)
        //时间差
        let reduceTime : TimeInterval = currentTime - timeSta
        //时间差小于60秒
        if reduceTime < 60 {
            return "刚刚"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins)分钟前"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours)小时前"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days)天前"
        }
        //不满足上述条件---或者是未来日期-----直接返回日期
        let date = NSDate(timeIntervalSince1970: timeSta)
        let dfmatter = DateFormatter()
        //yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat="yyyy年MM月dd日 HH:mm:ss"
        return dfmatter.string(from: date as Date)
    }
}

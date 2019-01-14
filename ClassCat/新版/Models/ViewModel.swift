//
//  ViewModels.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/19.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit

class ViewModel: NSObject {

    var contengImageHeight:CGFloat = 0
    
    var contentHeight:CGFloat = 0
    
    var mp3Height:CGFloat = 0
    
    var imgArr:[String] = [String]()
    
    var knowledge:Knowledge? = nil {
        didSet{
            let imgDicArr:[Dictionary] = self.getArrayFromJSONString(jsonString: ((knowledge?.knowledgeImages)!)) as! [Dictionary<String, String>] as [Dictionary]
            for dic in imgDicArr {
                imgArr.append(dic["imageUrl"]!)
            }
            self.contengImageHeight = CGFloat(WBContentImageView.getHeight(imgDicArr.count))
            
            let labSize = knowledge?.knowledgeDescription?.size(font: UIFont.systemFont(ofSize: 14), maxSize: CGSize(width: kS_W, height: kS_H))
            
            self.contentHeight = 126 + self.contengImageHeight + labSize!.height
            
            if(knowledge?.knowledgeAudioUrl != nil && (knowledge?.knowledgeAudioUrl?.count)! > 0){
                mp3Height = 30
                self.contentHeight = 126 + self.contengImageHeight + labSize!.height + 50
            }
        }
    }
    
    func getArrayFromJSONString(jsonString:String) ->NSArray{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return array as! NSArray
        }
        return array as! NSArray
    }
}

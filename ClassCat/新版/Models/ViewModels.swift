//
//  ViewModels.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/19.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit

class ViewModel: NSObject {

    var contengImageHeight:Float = 0
    
    var contentHeight:Float = 0
    
    var knowledge:Knowledge? = nil {
        didSet{
            let imgArr = self.getArrayFromJSONString(jsonString: (knowledge?.knowledgeImages!)!)
            print(imgArr)
            self.contengImageHeight = WBContentImageView.getHeight(imgArr.count)
            self.contentHeight = 175+self.contengImageHeight
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

//
//  NetWorkTools.swift
//  DYZB
//
//  Created by YueAndy on 2017/10/24.
//  Copyright © 2017年 YueAndy. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

let KCurrentView = Global.shared.currentViewController()?.view

enum HttpType {
    case GET
    case POST
}

class NetWorkTools {
    
    class func requestData(method : HttpType , urlString : String , paraDic : [String : Any]? = nil , finishCallBack:@escaping (_ result : AnyObject) -> ()) {
        
        let urlString = "http://ketangmao-app.100memory.com/" + urlString
        
        let type = method == .GET ? HTTPMethod.get : HTTPMethod.post
        
        //不需要遮盖层
        if("knowledge.php?act=readKnowledge" != urlString){
            HUD.show(.progress)
        }
        
        Alamofire.request(urlString ,method: type ,parameters:paraDic).validate().responseJSON { response in
            HUD.hide()
            switch response.result {
            case .success:
                finishCallBack(response.result.value as AnyObject)
            case .failure(let error):
                print(error.localizedDescription)
                KCurrentView?.makeToast("网络不给力")
            }
        }
    }
    
    /// 图片上传
    ///
    /// - Parameters:
    ///   - urlString: 服务器地址
    ///   - params: 参数 ["token": "89757", "userid": "nb74110"]
    ///   - images: image数组
    ///   - success: 成功闭包
    ///   - failture: 失败闭包
    class func upload(urlString : String, params:[String:String]?, images: [UIImage], success: @escaping (_ response : Any?) -> (), failture : @escaping (_ error : Error)->()) {
        
        let urlString = "http://ketangmao-app.100memory.com/" + urlString
        HUD.show(.progress)
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if params != nil {
                for (key, value) in params! {
                    //参数的上传
                    multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                }
            }
            for (index, value) in images.enumerated() {
                let imageData = value.jpegData(compressionQuality: 0.5)   //JPEGRepresentation(value, 1.0)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                let str = formatter.string(from: Date())
                let fileName = str+"\(index)"+".png"
                multipartFormData.append(imageData!, withName: "file", fileName: fileName, mimeType: "image/png")
            }
        },
                         to: urlString,
                         headers: nil,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    HUD.hide()
                                    
                                    let result = response.result
                                    if result.isSuccess {
                                        success(response.value)
                                    }
                                }
                            case .failure(let encodingError):
                                HUD.hide()
                                failture(encodingError)
                            }
        }
        )
    }
    
    class func upload(urlString : String, params:[String:String]?, data:Data, success: @escaping (_ response : Any?) -> (), failture : @escaping (_ error : Error)->()) {
        
        let urlString = "http://ketangmao-app.100memory.com/" + urlString
        
        HUD.show(.progress)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if params != nil {
                for (key, value) in params! {
                    //参数的上传
                    multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                }
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let str = formatter.string(from: Date())
            let fileName = str + ".mp3"
            
            multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: "application/octet-stream")
        },
                         to: urlString,
                         headers: nil,
                         encodingCompletion: { encodingResult in
                            
                            
                            
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    HUD.hide()
                                    
                                    let result = response.result
                                    if result.isSuccess {
                                        success(response.value)
                                    }
                                }
                            case .failure(let encodingError):
                                HUD.hide()
                                failture(encodingError)
                            }
        }
        )
    }
}

//
//  Models.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/13.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit

struct  Result:Codable{
    var result:String?
}
//知识包图片
struct KnowledgeImg: Codable {
    var result:String?
    var imageUrl:String?
}

struct KnowledgeAudio: Codable {
    var result:String?
    var audioUrl:String?
}
//用户头像
struct IconModel: Codable {
    var ossObj:String?
    var headImgUrl:String?
    var result:String?
}

// 登录返回
struct LoginInfo :Codable{
    var mediaServerUrlL:String?
    var result: String?
    var defaultCourseId:String?
    var interServerUrl:String?
    var userInfo:UserInfo
    var versionResult:String?
    var updateContent:String?
    var APPLatestVersion:String?
    var imageUrl:String?
    var imageFileBytes:String?
}
//用户信息
struct UserInfo: Codable {
    var headImage:String?
    var country:String?
    var id:String?
    var city:String?
    var sex:String?
    var name:String?
    var province:String?
}
struct Knowledges:Codable{
    var result:String?
    var data:[Knowledge]?
}
//知识包
struct Knowledge:Codable {
    var knowledgeId:String?
    var createTime:String?
    var knowledgeTitle:String?
    var knowledgeDescription:String?
    var knowledgeAudioUrl:String?
    var knowledgeReadTotal:String?
    var knowledgeCherishedTotal:String?
    var knowledgeImages:String?
}

//课堂的基本信息
struct Course:Codable {
    var result:String?
    var createrName:String?
    var createrHeadImg:String?
    var schoolName:String?
    var title:String?
    var description:String?
    var knowledgeTotal:String?
    var courseSubscribedTotal:String?
    var knowledgeReadTotal:String?
    var knowledgeCherishedTotal:String?
}


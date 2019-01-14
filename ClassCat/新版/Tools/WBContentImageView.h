//
//  WBImageContentView.h
//  Weibo
//
//  Created by SKY on 15/5/26.
//  Copyright (c) 2015年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBContentImageView : UIView

@property(strong,nonatomic)NSMutableArray *urlArray;




/**
 获取高度

 @param count 图片数
 @return 高度
 */
+(float)getContentImageViewHeight:(NSInteger)count;

@end

//
//  PCMTurnToMp3.h
//  BWJY
//
//  Created by YueAndy on 2017/4/10.
//  Copyright © 2017年 YueAndy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YqsPcm2Mp3 : NSObject

+ (instancetype)sharedInstacn;

-(void)convertWithPcmPath:(NSString *)pcmPath mp3Path:(NSString *)mp3Path;

//-(int)convertPcm2Wav:(NSString *)pcmPath wavPath:(NSString *)wavPath;

@end

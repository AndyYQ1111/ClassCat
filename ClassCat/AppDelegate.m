//
//  AppDelegate.m
//  ClassCat
//
//  Created by YueAndy on 2018/12/12.
//  Copyright © 2018年 pingan. All rights reserved.
//

#import "AppDelegate.h"
#import "JLDefine.h"

@interface AppDelegate (){
    JL_BLEApple     *bleCtrl;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //向微信注册
    [WXApi registerApp:@"wxd930ea5d5a258f4f"];
    [[UITabBar appearance] setTranslucent:NO];
    
    NSString * xianzai = [self getsTheCurrentTime];
    NSInteger yuyue = [self dateToTimeStampAtThe:@"2018-11-16 21:05:10"];
    NSInteger xianz = [self dateToTimeStampAtThe:xianzai];
    if (xianz > yuyue) {
        NSLog(@"过期时间");
    }else{
        NSLog(@"预定闹钟");
    }

    /*--- 检测当前语言 ---*/
    if (![kJL_GET hasPrefix:@"zh-Hans"]) {
        kJL_SET("en");
    }else{
        kJL_SET("zh-Hans");
    }

    /*--- 锁屏控制 ---*/
    [application beginReceivingRemoteControlEvents];

    [self addNote];
    /*--- JL_BLE SDK接入 --*/
    JL_BLEUsage *JL_ug = [JL_BLEUsage sharedMe];
    bleCtrl = JL_ug.JL_ble_apple;

    /*--- 监听录音数据 ---*/
    [JL_Listen sharedMe];

    /*--- 删除聊天记录 ---*/
    [JL_Talk talkRemove];

    /*--- 设置屏幕常亮 ---*/
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [DFAction delay:1.0 Task:^{
        if (JL_ug.bt_status_phone) {
            /*--- 蓝牙4.0 回连 ---*/
            if (!JL_ug.bt_status_connect) {
                //                BOOL connectFlag = [[JL_Listen sharedMe] connectBLE];
                //                if(!connectFlag){
                //                    [bleCtrl startScanBLE];
                //                }
                /*--- 蓝牙4.0 提示 ---*/
                [DFAction delay:2.0 Task:^{
                    if (!JL_ug.bt_status_connect) {
                        [self alertBLE_IsOFF];
                    }
                }];
            }
            /*--- 蓝牙2.0（A2DP）连接检测 ---*/
            [DFAction delay:4.0 Task:^{
                AVAudioSessionRouteDescription *nowRoute = [[AVAudioSession sharedInstance] currentRoute];
                NSArray * outArr = nowRoute.outputs;
                AVAudioSessionPortDescription *outPort = outArr[0];
                NSLog(@"NOW BLE 2.0 --> %@  Type:%@",outPort.portName,outPort.portType);
                if ([outPort.portType isEqual:@"Speaker"]) {
                    [self alertA2DP_IsOFF];
                }
            }];
        }
    }];

    
    return YES;
}



- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    BOOL isSuc = [WXApi handleOpenURL:url delegate:self];
    NSLog(@"url %@ isSuc %d",url,isSuc == YES ? 1 : 0);
    return  isSuc;
}


-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%lu bytes\n\n", msg.title, msg.description, obj.extInfo, (unsigned long)msg.thumbData.length];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)alertBLE_IsOFF {
    //[self showAlert:@"请在APP左侧边栏，连接设备蓝牙4.0。" Tag:0];
}

-(void)alertA2DP_IsOFF {
    [self showAlert:@"请连接设备蓝牙2.0" Tag:123];
    //     [self showAlert:@"请先打开并连接蓝牙设备" Tag:123];
}


-(void)showAlert:(NSString*)text Tag:(NSInteger)tag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"手机蓝牙设置"
                                                    message:text
                                                   delegate:self cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"好", nil];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未搜索到蓝牙设备"
    //                                                    message:text
    //                                                   delegate:self cancelButtonTitle:@"取消"
    //                                          otherButtonTitles:@"好", nil];
    alert.tag = tag;
    [alert show];
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^(){
    }];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}

-(void)remoteControlReceivedWithEvent:(UIEvent*)event{
    if (event) [DFAudioPlayer receiveRemoteEvent:event];
}

-(void)disconnectBT{
    [[JL_Listen sharedMe] setConnectBLE:YES];
    [bleCtrl disconnectBLE];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isLogin"];
    [application endReceivingRemoteControlEvents];
    [DFNotice remove:@"DISCONNECT_BT" Own:self];
    [self noteBTDisconnected:nil];
}

-(void)noteBTDisconnected:(NSNotification *)note{
    [bleCtrl disconnectBLE];
    [bleCtrl cleanBLE];
}


-(void)addNote{
    [DFNotice add:@"DISCONNECT_BT" Action:@selector(disconnectBT) Own:self];
    [DFNotice add:kUI_DEVICE_DISCONNECT Action:@selector(noteBTDisconnected:) Own:self];
    [DFNotice add:kUI_DISCONNECTED Action:@selector(noteBTDisconnected:) Own:self];
}

//获取时间戳
- (NSInteger)dateToTimeStampAtThe:(NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *lastDate = [formatter dateFromString:date];
    return [lastDate timeIntervalSince1970];
}
//获取当前时间
- (NSString *)getsTheCurrentTime{
    NSDate * da = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString * string = [formatter stringFromDate:da];
    return string;
}



@end

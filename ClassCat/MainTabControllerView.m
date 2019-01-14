//
//  MainTabControllerView.m
//  IntelligentBox
//
//  Created by jieliapp on 2017/11/10.
//  Copyright © 2017年 Zhuhia Jieli Technology. All rights reserved.
//

#import "MainTabControllerView.h"
#import "MusicFMViewController.h"
#import "LivesServiceViewController.h"
#import "JLDefine.h"
#import "SpeechHandle.h"
#import "ChatVC.h"
#import "SpeekingView.h"
#import "GetLocalization.h"
#import "ClassCat-Swift.h"


@interface MainTabControllerView ()<UITabBarDelegate>{
    
    __weak IBOutlet UITabBar *mainTabBar;
    
    UIButton         *mainBtn;
    JL_Listen        *mListen;
    SpeekingView     *spView;
}
@property(nonatomic,strong)UIViewController *topViewController;
@end

@implementation MainTabControllerView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mListen = [JL_Listen sharedMe];
   
    [self addNote];

    UIView *launchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kJL_W, kJL_H)];
    UIImageView *learchView = [[UIImageView alloc] initWithFrame:launchView.frame];
    learchView.image = [UIImage imageNamed:@"k36_bg"];
    [launchView addSubview:learchView];

    launchView.frame = [UIApplication sharedApplication].keyWindow.frame;
    [self.view addSubview:launchView];
    [UIView animateWithDuration:1.2 animations:^{

    } completion:^(BOOL finished) {
        [launchView removeFromSuperview];

        [self stepUpViewControllers];
        self.view.backgroundColor = [UIColor whiteColor];

        [[DFAudioPlayer sharedMe] reloadPhoneMusic];
        ///////*******接收通知*****//////////
        [SpeechHandle sharedInstance];

        [self setSelectedIndex:0];
        //获取
        [[GetLocalization sharedInstance] startUpdateLocalization:^(NSString *province,NSString *city) {
            [SpeechHandle sharedInstance].currentCity = city;
            [SpeechHandle sharedInstance].currentProsince = province;
        }];
    }];
}


/**
 设置TabBar ViewControllers
 */
-(void)stepUpViewControllers {
    
//    UIColor *selectColor = [UIColor colorWithRed:37.0/255.0 green:112.0/255.0 blue:255.0/255.0 alpha:1];
    // 课堂
    UINavigationController *crNac = [[BaseNavigationController alloc]initWithRootViewController:[ClassRoomVC new]];
    crNac.tabBarItem.image = [[UIImage imageNamed:@"tab_ketang_n"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageCR = [UIImage imageNamed:@"tab_ketang_s"];
    imageCR = [imageCR imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [crNac.tabBarItem setSelectedImage:imageCR];
    
    //音乐FMViewController
    UINavigationController *musicNav = [[BaseNavigationController alloc]initWithRootViewController:[MusicFMViewController new]];
    musicNav.tabBarItem.image = [[UIImage imageNamed:@"tab_neirong_n"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageMusic = [UIImage imageNamed:@"tab_neirong_s"];
    imageMusic = [imageMusic imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [musicNav.tabBarItem setSelectedImage:imageMusic];
    mainTabBar.delegate = self;
    
    UINavigationController *profileNav = [[BaseNavigationController alloc]initWithRootViewController:[ProfileVC new]];
    profileNav.tabBarItem.image = [[UIImage imageNamed:@"tab_wo_n"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageFN = [UIImage imageNamed:@"tab_wo_s"];
    imageFN = [imageFN imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [profileNav.tabBarItem setSelectedImage:imageFN];

    self.viewControllers = [NSArray arrayWithObjects:crNac,musicNav,profileNav,nil];
    musicNav.tabBarItem.title = @"音乐电台";
    profileNav.tabBarItem.title = @"我的";
    mainTabBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:70.0/255.0 blue:140.0/255.0 alpha:1];
    mainTabBar.barTintColor = [UIColor whiteColor];
    
    spView = [[SpeekingView alloc] initWithFrame:CGRectMake(0, 0, kJL_W, kJL_H)];
    [self.view addSubview:spView];
    spView.hidden = YES;
    self.tabBarController.hidesBottomBarWhenPushed = YES;
}

////设备点击开启录音
-(void)noteSpeechStart:(NSNotification*)note {
    NSString *obj = [note object];
    if (spView.hidden == NO) return;
    if([obj isEqualToString:@"0"]){
        if(self.selectedIndex != 1){
            UINavigationController *nav = self.selectedViewController;
            [nav popToRootViewControllerAnimated:NO];
        }else{
            if([self.topViewController isKindOfClass:[ChatVC class]]){
                return;
            }else{
                for (int i = 0; i<4; i++) {
                    if(![self.topViewController isKindOfClass:[MusicFMViewController class]]){
                        [self.topViewController dismissViewControllerAnimated:NO completion:nil];
                    }else{
                        break;
                    }
                }
            }
        }
        
        [self setSelectedIndex:1];
        [DFAction mainTask:^{
            UIViewController *selectedVC = self.selectedViewController;
            //录音创建知识包
            ChatVC *nextvc = [[ChatVC alloc]init];
            nextvc.isDevRecord = YES;
            [selectedVC presentViewController:nextvc animated:YES completion:nil];
        }];
    }else{  //创建知识包
        if(self.selectedIndex == 1){
            UIViewController *currentVC = self.topViewController;
            for (int i = 0; i<4; i++) {
                if(![currentVC isKindOfClass:[MusicFMViewController class]]){
                    [currentVC dismissViewControllerAnimated:NO completion:nil];
                }else{
                    break;
                }
            }
        }
        
        UINavigationController *oldNav = self.selectedViewController;
        [oldNav popToRootViewControllerAnimated:NO];
        
        [self setSelectedIndex:0];
        
        UINavigationController *nav = self.selectedViewController;
        //录音创建知识包
        
        AddPackageVC *nextvc = [[AddPackageVC alloc]init];
        nextvc.isDevRecord = @"1";
        [nav pushViewController:nextvc animated:YES];
    }
}

-(void)noteAppBackground:(NSNotification*)note {
    //停止录音(UI)
    NSLog(@"UIGestureRecognizerStateEnded");
    [mainBtn setImage:[UIImage imageNamed:@"k_ intercom"] forState:UIControlStateNormal];
    spView.hidden = YES;
    [spView stopAnimation];
}

-(void)addNote{
    [DFNotice add:UIApplicationDidEnterBackgroundNotification
           Action:@selector(noteAppBackground:) Own:self];
    [DFNotice add:@"speech_start" Action:@selector(noteSpeechStart:) Own:self];
}


-(void)dealloc {
    [DFNotice remove:UIApplicationDidEnterBackgroundNotification Own:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController*)topViewController
{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end

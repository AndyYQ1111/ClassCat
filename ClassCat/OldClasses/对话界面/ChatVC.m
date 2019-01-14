//
//  ChatVC.m
//  IntelligentBox
//
//  Created by DFung on 2017/11/17.
//  Copyright © 2017年 Zhuhia Jieli Technology. All rights reserved.
//

#import "ChatVC.h"
#import "ChatCell.h"
#import "SpeechHandle.h"
#import "SpeekingView.h"
//#import "JL_BDSpeechAI.h"

@interface ChatVC ()<UITableViewDelegate,
                     UITableViewDataSource>
{
    __weak IBOutlet UITableView *subTableView;
    __weak IBOutlet UIImageView *subImg;
    __weak IBOutlet UILabel *subLb;
    __weak IBOutlet UIButton *btn_recode;
    NSArray *dataArray;
    SpeekingView     *spView;
}
@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    subTableView.delegate = self;
    subTableView.dataSource = self;
    subTableView.backgroundColor = [UIColor clearColor];
    subTableView.tableFooterView = [UIView new];
    subTableView.allowsSelection = NO;
    
    spView = [[SpeekingView alloc] initWithFrame:CGRectMake(0, 0, kJL_W, kJL_H)];
    [self.view addSubview:spView];
    spView.hidden = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mainLongBtnAction:)];
    longPress.minimumPressDuration = 0.15;
    [btn_recode addGestureRecognizer:longPress];
 
    [self addNote];
    
    if(_isDevRecord == YES){
        spView.hidden = NO;
        [spView startAnimation];
        
        [DFAction delay:10.0 Task:^{
            [self noteSpeechEnd:nil];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    dataArray = [JL_Talk talkRed];
    [subTableView reloadData];
}

-(void)setUINot{
    subLb.hidden = NO;
    subImg.hidden = NO;
    subTableView.hidden = YES;
}

-(void)setUIHave{
    subLb.hidden = YES;
    subImg.hidden = YES;
    subTableView.hidden = NO;
}
- (IBAction)recordAction:(UIButton *)sender {
    
}

#pragma mark -center长按事件
-(void )mainLongBtnAction:(UILongPressGestureRecognizer *)sender {
    [DFNotice post:kDFAudioPlayer_NOTE Object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DFAudioPlayer currentPlayer] didPause];
    });
    
    if (sender.state == UIGestureRecognizerStateEnded) { //停止录音
        [JL_Listen.sharedMe recordStop];
        [btn_recode setImage:[UIImage imageNamed:@"k_ intercom"] forState:UIControlStateNormal];
        spView.hidden = YES;
        [spView stopAnimation];
        //转场音乐
        [[SpeechHandle sharedInstance] playCutToMusic];
    }
    else if (sender.state == UIGestureRecognizerStateBegan) { //开启录音
        //开始之前停止tts播放
        [[SpeechHandle sharedInstance] stopCutTopMusic];
        BOOL isOk = [JL_Listen.sharedMe recordStart];
        if (isOk) {
            [btn_recode setImage:[UIImage imageNamed:@"k39_record"] forState:UIControlStateNormal];
            spView.hidden = NO;
            [spView startAnimation];
        }
    }
}

- (IBAction)menuBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 对话记录回调 
-(void)noteTalkRecond:(NSNotification *)note {
    NSDictionary *info = [note object];
    [JL_Talk talkWrite:info];
    [self setUIHave];
    
    dataArray = [JL_Talk talkRed];
    [subTableView reloadData];
    [self scrollToBottom];
}


-(void)noteSpeechEnd:(NSNotification*)note {
    NSLog(@"---noteSpeechEnd");
    [DFAction mainTask:^{
        [self->spView stopAnimation];
        self->spView.hidden = YES;
//        [self->mainBtn setImage:[UIImage imageNamed:@"k_ intercom"] forState:UIControlStateNormal];
    }];
}

-(void)noteAppBackground:(NSNotification*)note {
    //停止录音(UI)
    NSLog(@"UIGestureRecognizerStateEnded");
//    [mainBtn setImage:[UIImage imageNamed:@"k_ intercom"] forState:UIControlStateNormal];
    spView.hidden = YES;
    [spView stopAnimation];
}



-(void)scrollToBottom {
    if(dataArray.count>0){
    NSIndexPath *ip = [NSIndexPath indexPathForRow:dataArray.count - 1 inSection:0];
    [subTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *info = dataArray[indexPath.row];
    CGFloat h = [ChatCell cellHeight:info];
    return h;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[ChatCell ID]];
    if (cell == nil) {
        cell = [[ChatCell alloc] init];
    }
    NSDictionary* info = dataArray[indexPath.row];
    [cell setInfo:info];
    return cell;
}

-(void)addNote{
    [DFNotice add:UIApplicationDidEnterBackgroundNotification
           Action:@selector(noteAppBackground:) Own:self];
    [DFNotice add:@"speech_end" Action:@selector(noteSpeechEnd:) Own:self];
    [DFNotice add:kJL_BDTalk Action:@selector(noteTalkRecond:) Own:self];
}

-(void)dealloc{
    [DFNotice remove:kJL_BDTalk Own:self]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

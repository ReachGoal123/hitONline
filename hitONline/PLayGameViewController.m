//
//  PLayGameViewController.m
//  hitONline
//
//  Created by wanglin on 15-3-26.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "PLayGameViewController.h"
#import "AsyncSocket.h"
#import "Mouse.h"
@interface PLayGameViewController ()<AsyncSocketDelegate>
@property(nonatomic,strong)AsyncSocket *serverSc;
@property(nonatomic,strong)AsyncSocket *clientSocket;
@property(nonatomic,strong)AsyncSocket *mynewSocket;
@end

@implementation PLayGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"等待玩家进入。。。";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回首页" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backItem;
    if (self.Ghost) {//客户端
        self.clientSocket = [[AsyncSocket alloc]initWithDelegate:self];
        [self.clientSocket connectToHost:self.Ghost onPort:8000 error:nil];
    }else{//服务器
        self.serverSc = [[AsyncSocket alloc]initWithDelegate:self];
        [self.serverSc acceptOnPort:8000 error:nil];
    }
    
}
-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    self.mynewSocket = newSocket;
}
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    self.title = [NSString stringWithFormat:@"已经和%@开始游戏",host];
    if (self.Ghost) {
        [self.clientSocket readDataWithTimeout:-1 tag:0];
    }else{
        [self.mynewSocket readDataWithTimeout:-1 tag:0];
    }
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self.view];
    NSValue *pointV = [NSValue valueWithCGPoint:p];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:pointV];
    if (self.Ghost) {
        [self.clientSocket writeData:data withTimeout:-1 tag:0];
    }else{
        [self.mynewSocket writeData:data withTimeout:-1 tag:0];
    }
    
}
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSValue *p = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    CGPoint point = [p CGPointValue];
    [self addMouseAtPoint:point];
    [sock readDataWithTimeout:-1 tag:0];
    
}
-(void)addMouseAtPoint:(CGPoint)point{
   Mouse *Mos = [[Mouse alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    Mos.center = point;
    
    [self.view addSubview:Mos];
    
}
-(void)backAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

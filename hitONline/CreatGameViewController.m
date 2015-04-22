//
//  CreatGameViewController.m
//  hitONline
//
//  Created by wanglin on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "CreatGameViewController.h"

@interface CreatGameViewController ()<UIAlertViewDelegate>
@property(nonatomic,strong)AsyncUdpSocket *myUdpSocket;
@property(nonatomic,strong)NSString *currentHost;
@end

@implementation CreatGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   self.myUdpSocket = [[AsyncUdpSocket alloc]initWithDelegate:self];
    [self.myUdpSocket bindToPort:9000 error:nil];
    [self.myUdpSocket enableBroadcast:YES error:nil];
    [self.myUdpSocket receiveWithTimeout:-1 tag:0];
    
}
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    if ([host hasPrefix:@":"]) {
        NSString *info = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if ([info isEqualToString:@"谁在线"]) {
            NSData *onlinedata = [@"我在线" dataUsingEncoding:NSUTF8StringEncoding];
            [self.myUdpSocket sendData:onlinedata toHost:host port:9000 withTimeout:-1 tag:0];
        
        }else if ([info isEqualToString:@"请求开始"]){
            NSString *message = [NSString stringWithFormat:@"%@请求开始游戏",host];
            UIAlertView  *alertv = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
            [alertv show];
            
            
        }
    
}
    self.currentHost = host;
    [self.myUdpSocket receiveWithTimeout:-1 tag:0];
    return YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        NSData *onlinedata = [@"拒绝" dataUsingEncoding:NSUTF8StringEncoding];
        [self.myUdpSocket sendData:onlinedata toHost:self.currentHost port:9000 withTimeout:-1 tag:0];
    }else{
        NSData *onlinedata = [@"同意" dataUsingEncoding:NSUTF8StringEncoding];
        [self.myUdpSocket sendData:onlinedata toHost:self.currentHost port:9000 withTimeout:-1 tag:0];
        [self performSegueWithIdentifier:@"GameVC" sender:nil];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [self.myUdpSocket close];
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

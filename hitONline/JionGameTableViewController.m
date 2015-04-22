//
//  JionGameTableViewController.m
//  hitONline
//
//  Created by wanglin on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "JionGameTableViewController.h"
#import "AsyncUdpSocket.h"
#import "PLayGameViewController.h"
@interface JionGameTableViewController ()
@property(nonatomic,strong)AsyncUdpSocket *myudpsocket;
@property(nonatomic,strong)NSMutableArray *gameHosts;
@property(nonatomic,strong)UIAlertView *myAlertV;
@property(nonatomic,strong)NSTimer *timer;
@end

@implementation JionGameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameHosts = [NSMutableArray array];
    self.myudpsocket = [[AsyncUdpSocket alloc]initWithDelegate:self];
    [self.myudpsocket bindToPort:9000 error:nil];
    [self.myudpsocket enableBroadcast:YES error:nil];
    [self.myudpsocket receiveWithTimeout:-1 tag:0];
    
    [self checkingGames];
    
   self.timer =  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkingGames) userInfo:nil repeats:YES];
}
-(void)checkingGames{
    
    NSData *data = [@"谁在线" dataUsingEncoding:NSUTF8StringEncoding];
    [self.myudpsocket sendData:data toHost:@"255.255.255.255" port:9000 withTimeout:-1 tag:0];
}


-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    if ([host hasPrefix:@":"]) {
        NSString *info = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if ([info isEqualToString:@"我在线"]) {
            if ([self.gameHosts containsObject:host]) {
                [self.gameHosts addObject:host];
                [self.tableView reloadData];
            }
            
        }else if ([info isEqualToString:@"拒绝"]){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"对方拒绝游戏" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"再试一次", nil];
            [alert show];
            
            
            
        }else if ([info isEqualToString:@"同意"]){
            if ([self.myAlertV isVisible]) {
                [self.myAlertV dismissWithClickedButtonIndex:0 animated:YES];
            }
            
            [self performSegueWithIdentifier:@"GameVC" sender:host];
            
            
        }
        
    }
    [self.myudpsocket receiveWithTimeout:-1 tag:0];
    return YES;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [self.timer invalidate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    return self.gameHosts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *info = self.gameHosts[indexPath.row];
    cell.textLabel.text =[NSString stringWithFormat:@"%@的游戏", [[info componentsSeparatedByString:@"."]lastObject]];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *host = self.gameHosts[indexPath.row];
    NSData *data = [@"请求开始" dataUsingEncoding:NSUTF8StringEncoding];
    [self.myudpsocket sendData:data toHost:host port:9000 withTimeout:-1 tag:0];
    self.myAlertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求已经发出  等待主机响应" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
    [self.myAlertV show];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
   
    PLayGameViewController *vc =  segue.destinationViewController;
    vc.Ghost = sender;
    
}


@end

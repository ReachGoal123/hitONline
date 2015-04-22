//
//  Mouse.m
//  hitONline
//
//  Created by wanglin on 15-3-26.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "Mouse.h"

@implementation Mouse
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:@"3" forState:UIControlStateNormal];
        self.backgroundColor = [UIColor redColor];
        [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
        
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(countDownAction:) userInfo:nil repeats:YES];
        
    }
    return self;
}

-(void)countDownAction:(NSTimer*)timer{
    int time = [[self titleForState:UIControlStateNormal] intValue];
    [self setTitle:[NSString stringWithFormat:@"%d",--time] forState:UIControlStateNormal];
    if (time==0) {
        [timer invalidate];
        [self removeFromSuperview];
    }
    
}
-(void)clicked{
    
    [self removeFromSuperview];
}


@end

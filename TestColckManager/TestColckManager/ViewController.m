//
//  ViewController.m
//  TestColckManager
//
//  Created by Coody on 2015/10/18.
//  Copyright © 2015年 Coody. All rights reserved.
//

#import "ViewController.h"

// for ClockManager
#import "ClockManager.h"


// 測試用鬧鐘 Tag
NSUInteger const K_REGISTER_PHONE_CLOCK = 11111;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (nonatomic , strong) NormiClock *clock;
@end

@implementation ViewController

- (IBAction)pressedButton:(UIButton *)sender {
//    _clock = [[ClockManager sharedInstance] getRandomClockWithSecond:10 withResponseBlock:^(NSUInteger second) {
//        
//        // 使用 weakSelf 避免記憶體遺漏
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        // 如果  ViewController 解構就不處理
//        if ( strongSelf != nil ) {
//            NSString *buttonTitle;
//            if ( second == 0 ) {
//                buttonTitle = @"開始";
//            }
//            else{
//                buttonTitle = [NSString stringWithFormat:@"倒數 %2lu 秒！" , (unsigned long)second];
//            }
//            [strongSelf->_testButton setTitle:buttonTitle forState:UIControlStateNormal];
//        }
//        
//    }];
    
    
    [[ClockManager sharedInstance] getClockWithSecond:60 
                                              withTag:K_REGISTER_PHONE_CLOCK 
                                            withBlock:[self responseBlock]];
    
}

-(void)dealloc{
    [_clock clearClock];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _testButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    
//    __weak __typeof(self) weakSelf = self;
//    [[ClockManager sharedInstance] restartColekWithSecond:60 
//                                                  WithTag:K_REGISTER_PHONE_CLOCK 
//                                                withBlock:^(NSUInteger second) 
//    {
//        // 使用 weakSelf 避免記憶體遺漏
//        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        // 如果  ViewController 解構就不處理
//        if ( strongSelf != nil ) {
//            NSString *buttonTitle;
//            if ( second == 0 ) {
//                buttonTitle = @"開始";
//            }
//            else{
//                buttonTitle = [NSString stringWithFormat:@"倒數 %2lu 秒！" , (unsigned long)second];
//            }
//            [strongSelf->_testButton setTitle:buttonTitle forState:UIControlStateNormal];
//        }
//    }];
    
    [[ClockManager sharedInstance] restartColekWithSecond:60 
                                                  WithTag:K_REGISTER_PHONE_CLOCK 
                                                withBlock:[self responseBlock]];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [_clock clearClock];
}

-(void(^)(NSUInteger))responseBlock{
    __weak __typeof(self)weakSelf = self;
    return ^(NSUInteger second){
        // 使用 weakSelf 避免記憶體遺漏
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@" isTickTick = %d" , [[ClockManager sharedInstance] isTickTick:K_REGISTER_PHONE_CLOCK]);
        
        // 如果  ViewController 解構就不處理
        if ( strongSelf != nil ) {
            NSString *buttonTitle;
            if ( second == 0 ) {
                buttonTitle = @"開始";
            }
            else{
                buttonTitle = [NSString stringWithFormat:@"倒數 %2lu 秒！" ,(unsigned long)second];
            }
            [strongSelf->_testButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
    };
}

@end

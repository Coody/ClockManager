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

// for Tools
#import "NSUserDefaults+Global.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *testButton;

@end

@implementation ViewController

- (IBAction)pressedButton:(UIButton *)sender {
    [[ClockManager sharedInstance] getClockWithSecond:60 
                                              withTag:K_REGISTER_PHONE_CLOCK 
                                            withBlock:^(NSString *second) 
    {
        NSString *buttonTitle;
        if ( [second isEqualToString:@"0"] ) {
            buttonTitle = @"開始";
        }
        else{
            buttonTitle = [NSString stringWithFormat:@"倒數 %@ 秒！" ,second];
        }
        [_testButton setTitle:buttonTitle forState:UIControlStateNormal];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [[ClockManager sharedInstance] restartColekWithSecond:60 
                                                  WithTag:K_REGISTER_PHONE_CLOCK 
                                                withBlock:^(NSString *second) 
    {
        NSString *buttonTitle;
        if ( [second isEqualToString:@"0"] ) {
            buttonTitle = @"開始";
        }
        else{
            buttonTitle = [NSString stringWithFormat:@"倒數 %@ 秒！" ,second];
        }
        [_testButton setTitle:buttonTitle forState:UIControlStateNormal];
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    
}

@end

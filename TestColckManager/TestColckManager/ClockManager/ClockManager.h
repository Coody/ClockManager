//
//  ClockManager.h
//  Prime
//
//  Created by Coody on 2015/10/16.
//  Copyright © 2015年 Coody. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSUInteger const K_REGISTER_PHONE_CLOCK;

/**
 * @brief - 時鐘管理者
 */
@interface ClockManager : NSObject

+(instancetype)sharedInstance;

/**
 * @warning - 此方法用在第一次啟動鬧鐘。
 * @brief   - 取得一個鬧鐘，給他總共要倒數的時間，以及一個特別的 Tag(NSUInteger)，一個每秒回應後要做事情的 Block，這個鬧鐘就會開始倒數
 * @details - 1. 此管理者會記住你設定過的鬧鐘，存在陣列內
 * @dedtils - 2. 當使用 getTimerString 時，會找出鬧鐘，設定時間給鬧鐘（鬧鐘內自行會判斷要顯示多少），最後把字串吐回來。
 * @details - 3. 當畫面去要到一個 Tag 過的鬧鐘以後，就會一直用同樣的鬧鐘，直到整個程式結束
 */
-(void)getClockWithSecond:(NSUInteger)tempSecond withTag:(NSUInteger)tempTag withBlock:(void(^)(NSUInteger second))responseBlock;

/**
 * TODO: 不用管內部倒數，只處理開始、結束的 Clock
 */
-(void)getClockWithSecond:(NSUInteger)tempSecond 
                  withTag:(NSUInteger)tempTag 
           withStartBlock:(void(^)(void))startResponseBlock 
             withEndBlock:(void(^)(void))endResponseBlock;

/**
 * @warning - 此方法用在 ViewController 在 WillAppear 時使用（是否恢復鬧鐘？）
 */
-(void)restartColekWithSecond:(NSUInteger)tempSecond WithTag:(NSUInteger)tempTag withBlock:(void(^)(NSUInteger second))responseBlock;

/* 在 ApplicationDidFinishLaunch 做 */
-(void)saveTime;

#pragma mark - 確認鬧鐘是否存在
-(BOOL)hasClock:(NSUInteger)tempClockIdentify;

@end

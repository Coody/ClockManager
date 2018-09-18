//
//  ClockManager.h
//
//
//  Created by Coody on 2015/10/16.
//
//

#import <Foundation/Foundation.h>


/**********************************************/
#pragma mark -
#pragma mark Clock
@interface NormiClock : NSObject
/**
 * @brief - 關閉 Clock ，解構使用
 */
-(void)clearClock;
@end


#pragma mark -
#pragma mark ClockManager
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
 *
 * @param   tempSecond    : 預設鬧鐘倒數秒數（為固定值）
 * @param   tempTag       : 設定鬧鐘獨一無二的 Tag
 * @param   responseBlock : 每秒倒數玩的回呼 block
 * @warning tag 請在此 ClockManager 內定義好！請勿自行定義，避免鬧鐘 Tag 重複到。
 */
-(void)getClockWithSecond:(NSUInteger)tempSecond
                  withTag:(NSUInteger)tempTag
                withBlock:(void(^)(NSUInteger second))responseBlock;

/**
 * TODO: 不用管內部倒數，只處理開始、結束的 Clock
 */
-(void)getClockWithSecond:(NSUInteger)tempSecond 
                  withTag:(NSUInteger)tempTag 
           withStartBlock:(void(^)(void))startResponseBlock
         withProcessBlock:(void(^)(NSUInteger second))processResponseBlock
             withEndBlock:(void(^)(void))endResponseBlock;

/**
 * @brief - 取得一個倒數計時的鬧鐘， ClockManager 不做管理。
 * @param tempSecond 秒數
 * @param responseBlock 每秒回應 block
 */
-(NormiClock *)getRandomClockWithSecond:(NSUInteger)tempSecond
                      withResponseBlock:(void(^)(NSUInteger second))responseBlock;

/**
 * @warning - 此方法用在 ViewController 在 WillAppear 時使用（是否恢復鬧鐘？）
 */
-(void)restartColekWithSecond:(NSUInteger)tempSecond
                      WithTag:(NSUInteger)tempTag
                    withBlock:(void(^)(NSUInteger second))responseBlock;

/* 在 ApplicationDidFinishLaunch 做 */
-(void)saveTime;

#pragma mark - 詢問鬧鐘相關資訊
/**
 * @brief - 詢問鬧鐘是否存在
 */
-(BOOL)hasClock:(NSUInteger)tempClockIdentify;

/**
 * @brief - 詢問鬧鐘是否正在倒數（必須是受管理的鬧鐘）
 */
-(BOOL)isTickTick:(NSUInteger)tempClockIdentify;

@end

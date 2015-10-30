//
//  ClockManager.m
//  Prime
//
//  Created by Coody on 2015/10/16.
//  
//

#import "ClockManager.h"

// for Tools
#import "NSDate+Interval.h"
#import "NSUserDefaults+Global.h"


NSUInteger const K_REGISTER_PHONE_CLOCK = 11111;

static NSString *const K_CLOCK_KEY = @"K_CLOCK_KEY_";
static NSString *const K_CLOCK_RECENT_TIME_KEY = @"K_CLOCK_RECENT_TIME_KEY_";
static NSString *const K_RECENT_TIME_KEY = @"K_RECENT_TIME_KEY_";

/**********************************************/
#pragma mark -
#pragma mark Clock
@interface SGTClock : NSObject

/** 
 * @brief - 取得此時鐘，除存在 UserDefault 的 NSDate 的時間 Key
 */
@property (nonatomic , readonly) NSString *clockKey;

/** 
 * @brief - 取得設定的總倒數時間 
 */
@property (nonatomic , readonly) NSUInteger defaultSecond;

/** 
 * @brief - 取得目前的倒數時間 NSUInteger 
 */
@property (nonatomic , readonly) NSInteger recentSecond;

/**
 * @brief - NSTimer 計時器
 */
@property (nonatomic , strong) NSTimer *recentTimer;

/**
 * @brief - 回呼函式（回傳 NSString ）
 */
@property (nonatomic , copy) void(^block)(NSUInteger second);

/**
 * @brief  - 初始化方法
 * @params - tempSecond    : 預設倒數總時間 (NSUInteger)
 * @params - tempTag       : 識別此 Clock 的 Tag (NSUInteger)
 * @params - responseBlock : 回呼函式
 */
-(instancetype)initWithDefaultSecond:(NSUInteger)tempSecond 
                             withTag:(NSUInteger)tempTag 
                           withBlock:(void(^)(NSUInteger second))responseBlock;

/***/
-(void)startClockWithBlock:(void(^)(NSUInteger second))responseBlock;

/**
 * @brief - 關閉 Clock ，解構使用
 */
-(void)clearTimer;

/**
 * @brief - 取得 Clock 的 Key
 */
+(NSString *)getClockKey:(NSUInteger)tempTag;

/**
 * @brief - 取得 Clock 關閉程式前的時間
 */
+(NSString *)getRecentSecondKey:(NSString *)tempTag;

@end

@implementation SGTClock
-(instancetype)init{return nil;};
-(void)dealloc{ [self clearTimer]; }

/* 初始化 */
-(instancetype)initWithDefaultSecond:(NSUInteger)tempSecond 
                             withTag:(NSUInteger)tempTag 
                           withBlock:(void(^)(NSUInteger second))responseBlock
{
    self = [super init];
    if ( self ) 
    {
        _clockKey = [SGTClock getClockKey:tempTag];
        _block = [responseBlock copy];
        _defaultSecond = tempSecond;
        _recentSecond = _defaultSecond;
        _recentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                        target:self 
                                                      selector:@selector(countDown) 
                                                      userInfo:nil 
                                                       repeats:YES];
        [self setRealSecond];
    }
    return self;
}


-(void)startClockWithBlock:(void(^)(NSUInteger second))responseBlock
{
    _block = nil;
    _block = responseBlock;
    if ( _recentSecond == 0 ) {
        _recentSecond = _defaultSecond;
    }
    [_recentTimer setFireDate:[NSDate date]];
}

/**
 * @brief   - 開放給時間管理者傳送真正需要數的時間（會取得真正的時間差）
 * @details - 通常在按 Home 鍵、或是 App 解構後，才需要用到。
 */
-(void)setRealSecond
{
    if ( [NSUserDefaults global_HasKey:_clockKey] ) {
        // 取得最後一次存入的時間
        NSTimeInterval second = [[NSUserDefaults global_ObjectForKey:_clockKey] timeIntervalSinceNow];
        // 取得最後一次倒數的時間（ 0 ~ defaultSecond 之間）
        NSUInteger latestSecond = [[NSUserDefaults global_ObjectForKey:[SGTClock getRecentSecondKey:_clockKey]] unsignedIntegerValue];
        self.recentSecond = (latestSecond + (int)second); 
    }
}

/** 轉成字串 */
-(NSString *)getSecondString{ return [NSString stringWithFormat:@"%lu" , _recentSecond]; }

/** 清除 Timer */
-(void)clearTimer{
    [_recentTimer invalidate];
    _recentTimer = nil;
    _recentSecond = 0;
}

-(void)saveClock{
    [NSUserDefaults global_SyncOjbect:[NSDate getToday] forKey:_clockKey];
    [NSUserDefaults global_SyncOjbect:[NSNumber numberWithUnsignedInteger:_recentSecond] 
                               forKey:[SGTClock getRecentSecondKey:_clockKey]];
}

-(void)removeSavedClock{
    [NSUserDefaults global_RemoveKey:_clockKey];
    [NSUserDefaults global_RemoveKey:[SGTClock getRecentSecondKey:_clockKey]];
}

#pragma mark - 內部方法
/** 覆寫 property 的 setter  */
-(void)setRecentSecond:(NSInteger)recentSecond
{
    if ( recentSecond <= 0 ) 
    {
        _recentSecond = 0;
        [_recentTimer setFireDate:[NSDate distantFuture]];
        [self removeSavedClock];
    }
    else if( recentSecond >= _defaultSecond )
    {
        _recentSecond = _defaultSecond - 1;
        [_recentTimer setFireDate:[NSDate getToday]];
        
        // TODO: 應該搬到 ApplicationDidFinishLaunch 去做（避免效能差）
        [self saveClock];
    }
    else
    {
        _recentSecond = recentSecond;
        
        // TODO: 應該搬到 ApplicationDidFinishLaunch 去做（避免效能差）
        [self saveClock];
    }
}

-(void)countDown{
    if ( _recentSecond <= 0 ) {
        self.recentSecond = 0;
    }
    else{
        self.recentSecond = _recentSecond - 1;
    }
    NSLog(@" 倒數計時：%lu" , _recentSecond);
    _block( _recentSecond );
}

+(NSString *)getClockKey:(NSUInteger)tempTag{
    return [NSString stringWithFormat:@"%@%lu" , K_RECENT_TIME_KEY , tempTag];
}

+(NSString *)getRecentSecondKey:(NSString *)tempTag{
    return [NSString stringWithFormat:@"%@%@" , K_CLOCK_RECENT_TIME_KEY , tempTag];
}

@end


/**********************************************/
#pragma mark -
#pragma mark TimerManager
@interface ClockManager()
@property (nonatomic , strong) NSMutableDictionary *clockDic;
@end

@implementation ClockManager

+(instancetype)sharedInstance{
    static ClockManager *sharedManager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (sharedManager == nil)
        {
            sharedManager = [[self alloc] initTimerManager];
        }
    });
    return sharedManager;
}

-(id)init{ return nil; }
-(id)initTimerManager{
    self = [super init];
    if ( self ) {
        _clockDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - 開放方法
-(void)getClockWithSecond:(NSUInteger)tempSecond withTag:(NSUInteger)tempTag withBlock:(void(^)(NSUInteger second))responseBlock{
    if ( tempSecond == 0 ) {
        NSLog(@" 鬧鐘設定倒數時間不為零！！請確認！");
        return;
    }
    else{
        NSString *clockKey = [self getClockKey:tempTag];
        SGTClock *clock = [_clockDic objectForKey:clockKey];
        if ( clock == nil ) {
            clock = [[SGTClock alloc] initWithDefaultSecond:tempSecond 
                                                    withTag:tempTag 
                                                  withBlock:responseBlock];
            
            // 將時鐘交給 TimerManager 來儲存管理
            [_clockDic setObject:clock forKey:clockKey];
        }
        else{
            [clock startClockWithBlock:responseBlock];
        }
    }
}

-(void)restartColekWithSecond:(NSUInteger)tempSecond WithTag:(NSUInteger)tempTag withBlock:(void(^)( NSUInteger second ))responseBlock{
    
    /*
     1. 去找 UserDefault 是否有存在的時間？
        a. 無 -> 不用做任何事情。
        b. 有 -> 去 _timerDic 中確認鬧鐘是否已經存在？
            b.1 存在 -> 去 UserDefault 找出之前的時間，現在時間 - 之前時間 = 差距時間 ，與時鐘的預設倒數時間相減後，丟到鬧鐘內自行處理。
            b.2 不存在 -> 將此鬧鐘的 Key & Object 存入 _clockDic 字典中，然後建立鬧鐘。
     */ 
    
    if ( [NSUserDefaults global_HasKey:[SGTClock getClockKey:tempTag]] ) {
        // b. 有 -> 去 _timerDic 中確認鬧鐘是否已經存在？
        [[ClockManager sharedInstance] getClockWithSecond:tempSecond withTag:tempTag withBlock:responseBlock];
    }
    else{
        // a. 無 -> 不用做任何事情。
    }
}

/* 在 ApplicationDidFinishLaunch 做 */
-(void)saveTime{
    for ( SGTClock *unitClock in _clockDic ) {
        [unitClock saveClock];
    }
}

#pragma mark - 確認鬧鐘是否存在
-(BOOL)hasClock:(NSUInteger)tempClockIdentify{
    BOOL hasClock = NO;
    if ( [_clockDic objectForKey:[self getClockKey:tempClockIdentify]] != nil ) {
        hasClock = YES;
    }
    return hasClock;
}

#pragma mark - 內部方法
-(NSString *)getClockKey:(NSUInteger)tempTag{
    return [NSString stringWithFormat:@"%@%lu" , K_CLOCK_KEY , (unsigned long)tempTag];
}

@end

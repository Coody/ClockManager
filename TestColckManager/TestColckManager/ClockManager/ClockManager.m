//
//  ClockManager.m
//
//
//  Created by Coody on 2015/10/16.
//  
//

#import "ClockManager.h"

//////////////////////////////////////////////
static NSString *const kDateFormat_yyyy_MM_dd_HH_mm_ss = @"yyyy-MM-dd HH:mm:ss";
//////////////////////////////////////////////

//////////////////////////////////////////////
static NSUInteger const K_RANDOM_CLOCK_KEY = 9999;/* 隨機產生的 clock 的 key （暫時不更動） */
//////////////////////////////////////////////
static NSString *const K_CLOCK_KEY = @"K_CLOCK_KEY_";
static NSString *const K_CLOCK_RECENT_TIME_KEY = @"K_CLOCK_RECENT_TIME_KEY_";
static NSString *const K_RECENT_TIME_KEY = @"K_RECENT_TIME_KEY_";
//////////////////////////////////////////////

/**********************************************/
#pragma mark - Tools Category
#pragma mark : NSUserDefaults + Global
@interface NSUserDefaults (Global)
/**
 * @brief 儲存到 value 到 standardUserDefaults
 */
+ (void)saveOjbect:(id)value forKey:(NSString*)keyName;

/**
 * @brief 取出 standardUserDefaults object
 */
+ (id)loadObjectForKey:(NSString*)keyName;

/**
 * @brief 判斷是否有此 key
 */
+ (BOOL)hasKey:(NSString*)keyName;

/**
 * @brief 清除此 key, 包含物件
 */
+ (void)removeKey:(NSString*)keyName;
@end

@implementation NSUserDefaults (Global)

// 儲存到 standardUserDefaults
+ (void)saveOjbect:(id)value forKey:(NSString*)keyName{
    [[self standardUserDefaults] setObject:value forKey:keyName];
    [[self standardUserDefaults] synchronize];
}

// 取出 standardUserDefaults object
+ (id)loadObjectForKey:(NSString*)keyName{
    return [[self standardUserDefaults] objectForKey:keyName];
}

// 判斷是否有此 key
+ (BOOL)hasKey:(NSString*)keyName{
    return ( [[self standardUserDefaults] objectForKey:keyName] != nil );
}

// 清除此 key, 包含物件
+ (void)removeKey:(NSString*)keyName{
    [[self standardUserDefaults] removeObjectForKey:keyName];
    [[self standardUserDefaults] synchronize];
}
@end

/**********************************************/
#pragma mark -
#pragma mark Clock
@interface NormiClock()

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
 * @brief - 是否正在倒數
 */
@property (nonatomic , assign) BOOL isTickTick;

/**
 * @brief - 回呼函式（回傳 NSString ）
 */
@property (nonatomic , copy) void(^block)(NSUInteger second);
@property (nonatomic , copy) void(^startBlock)(void);
@property (nonatomic , copy) void(^endBlock)(void);

/**
 * @brief  - 初始化方法
 * @params tempSecond    : 預設倒數總時間 (NSUInteger)
 * @params tempTag       : 識別此 Clock 的 Tag (NSUInteger)
 * @params responseBlock : 回呼函式
 */
-(instancetype)initWithDefaultSecond:(NSUInteger)tempSecond 
                             withTag:(NSUInteger)tempTag 
                           withBlock:(void(^)(NSUInteger second))responseBlock;

/**
 * @brief  - 初始化方法
 * @params tempSecond    : 預設倒數總時間 (NSUInteger)
 * @params tempTag       : 識別此 Clock 的 Tag (NSUInteger)
 * @params startBlock    : 開始倒數的 Block
 * @params processBlock  : 倒數過程中的 Block
 * @params endBlock      : 結束後的 Block
 */
-(instancetype)initWithDefaultSecond:(NSUInteger)tempSecond
                             withTag:(NSUInteger)tempTag
                      withStartBlock:(void(^)(void))startBlock
                    withProcessBlock:(void(^)(NSUInteger second))processBlock
                        withEndBlock:(void(^)(void))endBlock;

/**
 * @brief  - 產生一個用完即丟的鬧鐘
 */
-(instancetype)initRandomClockWithDefaultSecond:(NSUInteger)tempSecond
                                        withTag:(NSUInteger)tempTag
                                      withBlock:(void(^)(NSUInteger second))responseBlock;

/**
 * @brief - 
 */
-(void)startClockWithBlock:(void(^)(NSUInteger second))responseBlock;

/**
 * @brief - 取得 Clock 的 Key
 */
+(NSString *)getClockKey:(NSUInteger)tempTag;

/**
 * @brief - 取得 Clock 關閉程式前的時間
 */
+(NSString *)getRecentSecondKey:(NSString *)tempTag;

@end

@implementation NormiClock
-(instancetype)init{return nil;};
-(void)dealloc{ [self clearClock]; }

/* 初始化 */
-(instancetype)initWithDefaultSecond:(NSUInteger)tempSecond 
                             withTag:(NSUInteger)tempTag 
                           withBlock:(void(^)(NSUInteger second))responseBlock
{
    self = [super init];
    if ( self ) 
    {
        _isTickTick = NO;
        _clockKey = [NormiClock getClockKey:tempTag];
        _block = [responseBlock copy];
        _defaultSecond = tempSecond;
        _recentSecond = _defaultSecond;
        [self startClock];
        
        [self setRealSecond];
    }
    return self;
}

-(instancetype)initWithDefaultSecond:(NSUInteger)tempSecond
                             withTag:(NSUInteger)tempTag
                      withStartBlock:(void(^)(void))startBlock
                    withProcessBlock:(void(^)(NSUInteger second))processBlock
                        withEndBlock:(void(^)(void))endBlock
{
    self = [super init];
    if ( self ) {
        _isTickTick = NO;
        _clockKey = [NormiClock getClockKey:tempTag];
        _startBlock = [startBlock copy];
        _block = [processBlock copy];
        _endBlock = [endBlock copy];
        _defaultSecond = tempSecond;
        _recentSecond = _defaultSecond;
        [self startClock];
        
        [self setRealSecond];
        if ( _recentSecond == _defaultSecond ) {
            _startBlock();
        }
    }
    return self;
}

-(instancetype)initRandomClockWithDefaultSecond:(NSUInteger)tempSecond
                                        withTag:(NSUInteger)tempTag
                                      withBlock:(void(^)(NSUInteger second))responseBlock
{
    self = [super init];
    if ( self ) {
        _isTickTick = NO;
        _clockKey = [NormiClock getClockKey:tempTag];
        _defaultSecond = tempSecond;
        _recentSecond = _defaultSecond;
        _block = [responseBlock copy];
        [self startClock];
    }
    return self;
}

/**
 * 啟動計時
 */
-(void)startClockWithStartBlock:(void(^)(void))startBlock
               withProcessBlock:(void(^)(NSUInteger second))processBlock
                   withEndBlock:(void(^)(void))endBlock{
    // block 重新設定
    _startBlock = nil;
    _startBlock = startBlock;
    _block = nil;
    _block = processBlock;
    _endBlock = nil;
    _endBlock = endBlock;
    
    if ( _recentTimer == nil ) {
        _isTickTick = NO;
        _startBlock();
        [self startClock];
    }
    else{
        if ( _recentSecond <= 0 ) {
            _recentSecond = _defaultSecond;
            _startBlock();
        }
        [_recentTimer setFireDate:[NSDate date]];
    }
}

-(void)startClockWithBlock:(void(^)(NSUInteger second))responseBlock
{
    _block = nil;
    _block = responseBlock;
    if ( _recentSecond == 0 || _recentSecond > _defaultSecond ) {
        _isTickTick = NO;
        _recentSecond = _defaultSecond;
    }
    if( !self.isTickTick ){
        [_recentTimer setFireDate:[NSDate date]];
    }
}

/** 覆寫 property 的 setter  */
-(void)setRecentSecond:(NSInteger)recentSecond
{
    if ( recentSecond > (NSInteger)_defaultSecond ) {
        recentSecond = (NSInteger)_defaultSecond;
    }
    
    if ( recentSecond < 0 )
    {
        _isTickTick = NO;
        _recentSecond = 0;
        [_recentTimer setFireDate:[NSDate distantFuture]];
        [self removeSavedClock];
    }
    else if( recentSecond >= _defaultSecond )
    {
        _isTickTick = YES;
        _recentSecond = _defaultSecond - 1;
        [_recentTimer setFireDate:[NSDate date]];
        
        //        // TODO: 應該搬到 ApplicationDidFinishLaunch 去做（避免效能差）
        //        [self saveClock];
    }
    else
    {
        _isTickTick = YES;
        _recentSecond = recentSecond;
        
        //        // TODO: 應該搬到 ApplicationDidFinishLaunch 去做（避免效能差）
        //        [self saveClock];
    }
}

/**
 * @brief   - 開放給時間管理者傳送真正需要數的時間（會取得真正的時間差）
 * @details - 通常在按 Home 鍵、或是 App 解構後，才需要用到。
 */
-(void)setRealSecond
{
    if ( [NSUserDefaults hasKey:_clockKey] ) {
        // 取得最後一次存入的時間
        NSTimeInterval second = [[NSUserDefaults loadObjectForKey:_clockKey] timeIntervalSinceNow];
        // 取得最後一次倒數的時間（ 0 ~ defaultSecond 之間）
        NSUInteger latestSecond = [[NSUserDefaults loadObjectForKey:[NormiClock getRecentSecondKey:_clockKey]] unsignedIntegerValue];
        self.recentSecond = (latestSecond + (int)second); 
    }
}

/** 轉成字串 */
-(NSString *)getSecondString{ return [NSString stringWithFormat:@"%lu" ,  (unsigned long)_recentSecond]; }

/** 清除 Timer */
-(void)clearClock{
    [_recentTimer invalidate];
    _recentTimer = nil;
    _recentSecond = 0;
}

/** 暫時停止（當有開始計時的時候才有用）*/
-(void)pauseClock{
    if( [self isTickTick] ){
#ifdef DEBUG
        NSLog(@" pause clock key = %@" , self.clockKey);
#endif
        [_recentTimer invalidate];
        _recentTimer = nil;
        _isTickTick = NO;
    }
}

/** 繼續計時（當時鐘是停止的時候才有用）*/
-(void)startClock{
    if( ![self isTickTick] ){
#ifdef DEBUG
        NSLog(@" start clock key = %@" , self.clockKey);
#endif
        _isTickTick = YES;
        _recentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(countDown)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

#pragma mark - 內部方法
-(void)countDown{
    // 鬧鐘可以修正預設時間的功能
    // 修正 _recentSecond
    if ( _defaultSecond < _recentSecond ) {
        _recentSecond = _defaultSecond;
    }
    
    if ( _recentSecond <= 0 ) {
        self.recentSecond = -1;
        if( _endBlock ){
            _endBlock();
        }
        else{
            _block( _recentSecond );
        }
    }
    else{
        self.recentSecond = _recentSecond - 1;
        _block( _recentSecond );
    }
#ifdef DEBUG
    if( _recentSecond <= 5 || _recentSecond%5 == 0 ){
        NSLog(@" 倒數計時( %@ )：%lu" , _clockKey , (long)_recentSecond);
    }
#endif
}

-(void)saveClock{
    [NSUserDefaults saveOjbect:[NSDate date] forKey:_clockKey];
    [NSUserDefaults saveOjbect:[NSNumber numberWithUnsignedInteger:_recentSecond]
                        forKey:[NormiClock getRecentSecondKey:_clockKey]];
}

-(void)removeSavedClock{
    [NSUserDefaults removeKey:_clockKey];
    [NSUserDefaults removeKey:[NormiClock getRecentSecondKey:_clockKey]];
}

-(void)resetClockDefaultSecond:(NSUInteger)tempNewDefaultSecond{
    _defaultSecond = tempNewDefaultSecond;
}

-(BOOL)getIsTickTick{
    return _isTickTick;
}

+(NSString *)getClockKey:(NSUInteger)tempTag{
    return [NSString stringWithFormat:@"%@%lu" , K_RECENT_TIME_KEY , (unsigned long)tempTag];
}

+(NSString *)getRecentSecondKey:(NSString *)tempTag{
    return [NSString stringWithFormat:@"%@%@" , K_CLOCK_RECENT_TIME_KEY , tempTag];
}

@end


/**********************************************/
#pragma mark -
#pragma mark ClockManager
@interface ClockManager()
@property (nonatomic , strong) NSMutableDictionary *clockDic;
@property (nonatomic , assign) NSUInteger randomClockCount;
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
        _randomClockCount = 0;
    }
    return self;
}

#pragma mark - 開放方法
-(void)getClockWithSecond:(NSUInteger)tempSecond
                  withTag:(NSUInteger)tempTag
                withBlock:(void(^)(NSUInteger second))responseBlock
{
    NSString *clockKey = [self getClockKey:tempTag];
    NormiClock *clock = [_clockDic objectForKey:clockKey];
    if ( clock == nil ) {
        clock = [[NormiClock alloc] initWithDefaultSecond:tempSecond
                                                  withTag:tempTag
                                                withBlock:responseBlock];
        
        // 將時鐘交給 TimerManager 來儲存管理
        [_clockDic setObject:clock forKey:clockKey];
    }
    else{
        [clock resetClockDefaultSecond:tempSecond];
        [clock startClockWithBlock:responseBlock];
    }
}

-(void)getClockWithSecond:(NSUInteger)tempSecond
                  withTag:(NSUInteger)tempTag
           withStartBlock:(void(^)(void))startResponseBlock
         withProcessBlock:(void(^)(NSUInteger second))processResponseBlock
             withEndBlock:(void(^)(void))endResponseBlock
{
    NSString *clockKey = [self getClockKey:tempTag];
    NormiClock *clock = [_clockDic objectForKey:clockKey];
    if ( clock == nil ) {
        clock = [[NormiClock alloc] initWithDefaultSecond:tempSecond
                                                  withTag:tempTag
                                           withStartBlock:startResponseBlock
                                         withProcessBlock:processResponseBlock
                                             withEndBlock:endResponseBlock];
        
        // 將時鐘交給 TimerManager 來儲存管理
        [_clockDic setObject:clock forKey:clockKey];
    }
    else{
        [clock startClockWithStartBlock:startResponseBlock
                       withProcessBlock:processResponseBlock
                           withEndBlock:endResponseBlock];
    }
}

-(void)getClockWithSecond:(NSUInteger)tempSecond
                  withTag:(NSUInteger)tempTag
           withStartBlock:(void(^)(void))startResponseBlock
             withEndBlock:(void(^)(void))endResponseBlock
{
    NSString *clockKey = [self getClockKey:tempTag];
    NormiClock *clock = [_clockDic objectForKey:clockKey];
    if ( clock == nil ) {
        clock = [[NormiClock alloc] initWithDefaultSecond:tempSecond
                                                  withTag:tempTag
                                           withStartBlock:startResponseBlock
                                         withProcessBlock:nil
                                             withEndBlock:endResponseBlock];
        
        // 將時鐘交給 TimerManager 來儲存管理
        [_clockDic setObject:clock forKey:clockKey];
    }
    else{
        [clock startClockWithStartBlock:startResponseBlock
                       withProcessBlock:nil
                           withEndBlock:endResponseBlock];
    }
}

/**
 * @brief - 取得一個倒數計時的鬧鐘， ClockManager 不做管理。
 */
-(NormiClock *)getRandomClockWithSecond:(NSUInteger)tempSecond
                      withResponseBlock:(void(^)(NSUInteger second))responseBlock
{
    NormiClock *clock = nil;
    if ( tempSecond == 0 ) {
#ifdef DEBUG
        NSLog(@" 鬧鐘設定倒數時間不為零！！請確認！");
#endif
    }
    else{
        _randomClockCount++;
        clock = [[NormiClock alloc] initRandomClockWithDefaultSecond:tempSecond
                                                             withTag:(K_RANDOM_CLOCK_KEY*100+_randomClockCount) withBlock:responseBlock];
    }
    return clock;
}

-(NormiClock *)getRandomClockWithSecond:(NSUInteger)tempSecond 
                         withStartBlock:(void(^)(void))startResponseBlock
                       withProcessBlock:(void(^)(NSUInteger second))processResponseBlock
                           withEndBlock:(void(^)(void))endResponseBlock{
    NormiClock *clock = nil;
    if ( tempSecond == 0 ) {
#ifdef DEBUG
        NSLog(@" 鬧鐘設定倒數時間不為零！！請確認！");
#endif
    }
    else{
        _randomClockCount++;
        clock = [[NormiClock alloc] initWithDefaultSecond:tempSecond 
                                                  withTag:(K_RANDOM_CLOCK_KEY*100+_randomClockCount)
                                           withStartBlock:startResponseBlock 
                                         withProcessBlock:processResponseBlock 
                                             withEndBlock:endResponseBlock];
    }
    return clock;
}


-(void)restartColekWithSecond:(NSUInteger)tempSecond
                      WithTag:(NSUInteger)tempTag
                    withBlock:(void(^)( NSUInteger second ))responseBlock{
    
    /*
     1. 去找 UserDefault 是否有存在的時間？
     a. 無 -> 不用做任何事情。
     b. 有 -> 去 _timerDic 中確認鬧鐘是否已經存在？
     b.1 存在 -> 去 UserDefault 找出之前的時間，現在時間 - 之前時間 = 差距時間 ，與時鐘的預設倒數時間相減後，丟到鬧鐘內自行處理。
     b.2 不存在 -> 將此鬧鐘的 Key & Object 存入 _clockDic 字典中，然後建立鬧鐘。
     */ 
    
    if ( [NSUserDefaults hasKey:[NormiClock getClockKey:tempTag]] ) {
        // b. 有 -> 去 _timerDic 中確認鬧鐘是否已經存在？
        [[ClockManager sharedInstance] getClockWithSecond:tempSecond 
                                                  withTag:tempTag 
                                                withBlock:responseBlock];
    }
    else{
        // a. 無 -> 不用做任何事情。
    }
}

-(void)restartClockWithSecond:(NSUInteger)tempSecond 
                      withTag:(NSUInteger)tempTag 
               withStartBlock:(void(^)(void))startResponseBlock
             withProcessBlock:(void(^)(NSUInteger second))processResponseBlock
                 withEndBlock:(void(^)(void))endResponseBlock{
    /*
     1. 去找 UserDefault 是否有存在的時間？
     a. 無 -> 不用做任何事情。
     b. 有 -> 去 _timerDic 中確認鬧鐘是否已經存在？
     b.1 存在 -> 去 UserDefault 找出之前的時間，現在時間 - 之前時間 = 差距時間 ，與時鐘的預設倒數時間相減後，丟到鬧鐘內自行處理。
     b.2 不存在 -> 將此鬧鐘的 Key & Object 存入 _clockDic 字典中，然後建立鬧鐘。
     */ 
    
    if ( [NSUserDefaults hasKey:[NormiClock getClockKey:tempTag]] ) {
        // b. 有 -> 去 _timerDic 中確認鬧鐘是否已經存在？
        [[ClockManager sharedInstance] getClockWithSecond:tempSecond 
                                                  withTag:tempTag 
                                           withStartBlock:startResponseBlock 
                                         withProcessBlock:processResponseBlock 
                                             withEndBlock:endResponseBlock];
    }
    else{
        // a. 無 -> 不用做任何事情。
    }
}

-(void)removeClockWithTag:(NSUInteger)tempTag{
    NSString *key = [self getClockKey:tempTag];
    NormiClock *clock = [self.clockDic objectForKey:key];
    if( clock ){
        [clock removeSavedClock];
        [clock clearClock];
        [self.clockDic removeObjectForKey:key];
    }
}

/* 在 ApplicationDidFinishLaunch 做 */
-(void)saveTime{
    for ( NormiClock *unitClock in _clockDic.allValues ) {
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

-(BOOL)isTickTick:(NSUInteger)tempClockIdentify{
    BOOL isTickTick = NO;
    NormiClock *clock = [_clockDic objectForKey:[self getClockKey:tempClockIdentify]];
    if( clock != NULL ){
        isTickTick = [clock getIsTickTick];
    }
    return isTickTick;
}

#pragma mark - 內部方法
-(NSString *)getClockKey:(NSUInteger)tempTag{
    return [NSString stringWithFormat:@"%@%lu" , K_CLOCK_KEY , (unsigned long)tempTag];
}

@end

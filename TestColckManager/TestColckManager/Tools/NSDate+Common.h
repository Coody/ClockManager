//
//  NSDate+Common.h
//

#import <Foundation/Foundation.h>

extern NSString *const kDateFormat_yyyy_MM_dd_HH_mm_ss;
extern NSString *const kDateFormat_yyyy_MM_dd;

/**
 * @brief 簡易的時間間隔查詢
 */
@interface NSDate (Common)

#pragma mark - 查詢(Yes/NO)
/** 
 * @brief   - 查詢是否在 24 小時以內
 */
- (BOOL)dateInLast24Hours;

/**
 * @brief   - 查詢是否在 7 天以內
 */
- (BOOL)dateInLast7Days;

/**
 * @brief   - 查詢是否是今天以內？
 */
- (BOOL)dateInToday;

/**
 *  檢查兩時間a和b是否為同日.
 *
 *  @param aTimeInterval 比較時間 a
 *  @param bTimeInterval 比較時間 b
 *
 *  @return YES:同日，NO:非同日.
 */
+ (BOOL)isSameDay:(NSTimeInterval)aTimeInterval otherTime:(NSTimeInterval)bTimeInterval;

#pragma mark - NSString/NSTimeInterval 轉換
+ (NSTimeInterval)timeIntervalSince1970WithTimeString:(NSString *)aTimeString dateFormatString:(NSString *)aDataFormatString;

/**
 *  取得 long long 整數的 timeIntervalSince1970 毫秒（會跟 Android 一樣） 
 *
 *  @return 回傳 long long string 的 timeIntervalSince1970 的字串（已經轉成毫秒）
 */
+ (NSString *)getLongLongTimeIntervalSince1970;

#pragma mark - NSDate/NSString 轉換
/**
 * @brief   - 將 NSDate 轉成 NSString
 * @details - 格式為 yyyy/MM/dd
 */
+ (NSString *)getDateFormatter:(NSDate *)date;

/**
 * @brief   - 將 NSDate 轉成 NSString（自定格式）
 * @params  - formatterString 為自定的格式，如：@"yyyy/MM/dd"
 */
+ (NSString *)getDateFormatterWithDate:(NSDate *)date 
                   withFormatterString:(NSString *)formatterString;

/**
 * @brief   - 將 NSString 轉成 NSDate
 * @details - 格式為 yyyy_MM_dd
 */
+ (NSDate *)getDateFromString:(NSString *)tempDateString;

/**
 * @brief   - 將 NSString 轉成 NSDate（自定格式）
 * @params  - formatterString 為自定的格式，如：@"yyyy/MM/dd"
 */
+ (NSDate *)getDateFromString:(NSString *)tempDateString withFormatterString:(NSString *)formatterString;

#pragma mark - NSTimeInterval/NSString 轉換
+ (NSString *)dateStringFromTimeInterval:(NSTimeInterval)timeInterval dateFormatterString:(NSString *)dateFormatterString;

#pragma mark - 快速取得
/** 取得昨天的 NSDate */
+ (NSDate *)getYesturday; 

/** 取得今天的 NSDate */
+ (NSDate *)getToday;

/** 取得某天的 ?? 個月前的日期（請帶正數） */
+ (NSDate *)getCountMonthAgo:(NSInteger)tempInteger 
                    FromDate:(NSDate *)tempDate;

/** 取得某天的 100 年前日期 */
+ (NSDate *)get100YearsAgoFromDate:(NSDate *)tempDate;

/** 取得某天的 ？？ 年前日期（請帶正數） */
+ (NSDate *)getCountYearsAgo:(NSInteger)tempInteger 
                    FromDate:(NSDate *)tempDate;

@end

//
//  NSDate+Interval.h
//  Foundation
//

#import <Foundation/Foundation.h>

extern NSString *const kDateFormat_yyyy_MM_dd_HH_mm_ss;
extern NSString *const kDateFormat_yyyy_MM_dd;

/**
 * @brief 簡易的時間間隔查詢
 */
@interface NSDate (Interval)

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

#pragma mark - NSDate/NSString 轉換
/**
 * @brief   - 將 NSDate 轉成 NSString
 * @details - 格式為 yyyy_MM_dd
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

#pragma mark - 快速取得
/** 取得昨天的 NSDate */
+ (NSDate *)getYesturday; 

/** 取得今天的 NSDate */
+ (NSDate *)getToday;

/** 取得某天的 100 年前日期 */
+ (NSDate *)get100YearsAgoFromDate:(NSDate *)tempDate;

/** 取得某天的 ？？ 年前日期（請帶正數） */
+ (NSDate *)getCountYearsAgo:(NSInteger)tempInteger 
                    FromDate:(NSDate *)tempDate;

@end

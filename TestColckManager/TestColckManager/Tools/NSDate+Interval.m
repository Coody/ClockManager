//
//  NSDate+Interval.m
//  Foundation
//

#import "NSDate+Interval.h"

NSString *const kDateFormat_yyyy_MM_dd_HH_mm_ss = @"yyyy-MM-dd HH:mm:ss";
NSString *const kDateFormat_yyyy_MM_dd = @"yyyy/MM/dd";

@implementation NSDate (Interval)

#pragma mark - 查詢(Yes/NO)
- (BOOL)dateInLast24Hours
{
    if([[NSDate date] timeIntervalSinceDate:self] < (24*60*60))
    {
        return YES;
    }
    return NO;
    
}

- (BOOL)dateInLast7Days
{
    if([[NSDate date] timeIntervalSinceDate:self] < (7*24*60*60))
    {
        return YES;
    }
    return NO;
}

- (BOOL)dateInToday
{
    BOOL check = NO;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormat_yyyy_MM_dd_HH_mm_ss];
    NSString *strToday = [dateFormatter stringFromDate:[NSDate date]];
    NSString *strMsgDay = [dateFormatter stringFromDate:self];
    NSRange checkRange ;
    checkRange.length = 10;
    checkRange.location = 0;
    NSString *checkToday = [strToday substringWithRange:checkRange];
    NSString *checkMsgDay = [strMsgDay substringWithRange:checkRange];
    if ( [checkMsgDay isEqualToString:checkToday] ) {
        check = YES ;
    }
    return check;
}

#pragma mark - NSDate/NSString 轉換
+ (NSString *)getDateFormatter:(NSDate *)date{
    return [self getDateFormatterWithDate:date withFormatterString:kDateFormat_yyyy_MM_dd];
}

+ (NSString *)getDateFormatterWithDate:(NSDate *)date withFormatterString:(NSString *)formatterString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatterString];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)getDateFromString:(NSString *)tempDateString{
    return [self getDateFromString:tempDateString withFormatterString:kDateFormat_yyyy_MM_dd];
}

+ (NSDate *)getDateFromString:(NSString *)tempDateString withFormatterString:(NSString *)formatterString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatterString];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    return [dateFormatter dateFromString:tempDateString];
}

#pragma mark - 快速取得
/** 取得昨天的 NSDate */
+ (NSDate *)getYesturday{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    NSDate *tmpDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    return tmpDate;
}

/** 取得今天的 NSDate */
+ (NSDate *)getToday{
    return [NSDate date];
}

/** 取得某天的 100 年前日期 */
+ (NSDate *)get100YearsAgoFromDate:(NSDate *)tempDate{
    return [NSDate getCountYearsAgo:100 FromDate:tempDate];
}

/** 取得某天的 ？？ 年前日期（請帶正數） */
+ (NSDate *)getCountYearsAgo:(NSInteger)tempInteger 
                    FromDate:(NSDate *)tempDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:(tempInteger * -1)];
    NSDate *minimumDate = [calendar dateByAddingComponents:comps toDate:tempDate options:0];
    return minimumDate;
}

@end

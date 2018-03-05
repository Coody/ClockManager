//
//  NSDate+Common.h
//

#import "NSDate+Common.h"

NSString *const kDateFormat_yyyy_MM_dd_HH_mm_ss = @"yyyy-MM-dd HH:mm:ss";
NSString *const kDateFormat_yyyy_MM_dd = @"yyyy/MM/dd";

#define D_SV_TIMEZONE [NSTimeZone timeZoneForSecondsFromGMT:(3600*8)]

@implementation NSDate (Common)

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

+ (BOOL)isSameDay:(NSTimeInterval)aTimeInterval otherTime:(NSTimeInterval)bTimeInterval
{
    BOOL result = NO;
    
    //- NSString to NSDate
    NSDate *aDate = [NSDate dateWithTimeIntervalSince1970: aTimeInterval];
    NSDate *bDate = [NSDate dateWithTimeIntervalSince1970: bTimeInterval];;
    
    //- Check isToday
    {
        NSDateComponents *aDay  = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate: aDate];
        NSDateComponents *bDay  = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate: bDate];
        
        [aDay setTimeZone:D_SV_TIMEZONE];
        [bDay setTimeZone:D_SV_TIMEZONE];
        
        if([aDay day]      == [bDay day]   &&
           [aDay month]    == [bDay month] &&
           [aDay year]     == [bDay year]  &&
           [aDay era]      == [bDay era])
        {
            result = YES;
        }
        else
        {
            result = NO;
        }
    }

    return result;
}

#pragma mark - NSString/NSTimeInterval 轉換
+ (NSTimeInterval)timeIntervalSince1970WithTimeString:(NSString *)aTimeString dateFormatString:(NSString *)aDataFormatString
{
    return [self timeIntervalSince1970WithTimeString:aTimeString dateFormatString:aDataFormatString timeZone:D_SV_TIMEZONE];
}

+ (NSTimeInterval)timeIntervalSince1970WithTimeString:(NSString *)aTimeString dateFormatString:(NSString *)aDataFormatString timeZone:(NSTimeZone *)aTimeZone
{
    if (nil == aTimeString || nil == aDataFormatString || [@"" isEqualToString: aTimeString] || [@"" isEqualToString: aDataFormatString])
    {
        return 0;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:aDataFormatString];
    [dateFormatter setTimeZone:aTimeZone];
    
    NSDate *date = [dateFormatter dateFromString:aTimeString];
    
    return  [date timeIntervalSince1970];
}

+ (NSString *)getLongLongTimeIntervalSince1970
{
    
    long long date = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *dateString = [NSString stringWithFormat:@"%llu", date ];;
    return dateString;
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

#pragma mark - NSTimeInterval/NSString 轉換
+ (NSString *)dateStringFromTimeInterval:(NSTimeInterval)timeInterval dateFormatterString:(NSString *)dateFormatterString
{
    return [self dateStringFromTimeInterval:timeInterval dateFormatterString:dateFormatterString timeZone:D_SV_TIMEZONE];
}

+ (NSString *)dateStringFromTimeInterval:(NSTimeInterval)timeInterval dateFormatterString:(NSString *)dateFormatterString timeZone:(NSTimeZone *)aTimeZone
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //@"yyyy/MM/dd HH:mm:ss"
    [dateFormatter setDateFormat:dateFormatterString];
    [dateFormatter setTimeZone:aTimeZone];
    
    return [dateFormatter stringFromDate: date];
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

/** 取得某天的 ?? 個月前的日期（請帶正數） */
+ (NSDate *)getCountMonthAgo:(NSInteger)tempInteger 
                    FromDate:(NSDate *)tempDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:(tempInteger * -1)];
    NSDate *tmpDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    return tmpDate;
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
